function [] = runSpectrograms(dataPath, savePath, blnFocused)
   
    %FUNCTION DESCRIPTION: Function takes the downsampled-laplacian-referenced data 
    %and plots multi-taperspectrograms per electrode. blnFocused is true or
    %false: if true, will use spectrogram parameters for the short focused
    %data
    % Author: Daphne Toglia 4/2024
    % Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;
    t = datastruct.t;
    Fs = HDR.frequency(1);
    
    if ~exist(savePath, 'dir'), mkdir(savePath); end

    % Define parameters for multitaper spectrogram
    if blnFocused
        % For focused spectrogram
        params.Fs = Fs;             % Sampling frequency
        params.tapers = [2 3];        % Time-bandwidth product and the number of tapers [TW K]
        params.fpass = [0, 45];  % Frequency range of interest for focused spectrogram
        movingwin = [4 1];            % Window length is 4s and step size is 1s for overlap
    else
        % For full spectrogram
        params.Fs = Fs;             % Sampling frequency
        params.tapers = [5 8];        % Time-bandwidth product and the number of tapers [TW K]
        movingwin = [10 5];            % Window length is 10s and step size is 5s for overlap
    end
    
    % Run spectrogram
    fprintf('Running spectrograms... \n')
    [S, t_spec, f] = mtspecgramc(data', movingwin, params);
    
    % Loop through each channel and save the figure
    fprintf('Making Figures... \n')
    for i = 1:length(HDR.label)
        channelLabel = HDR.label{i};

        fig1 = figure('visible','off','position',[1, 929, 1090, 408]);  % Create an invisible figure
        subplot(1,2,1)
        imagesc(t_spec+t(1), f, 10*log10(S(:,:,i))');
        axis xy; colorbar;
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        title(['Electrode ' channelLabel]);
        subplot(1,2,2)
        plot(f, 10*log10(mean(S(:,:,i),1)));
        xlabel('Frequency (Hz)')
        ylabel('Power (dB)')
        saveas(fig1, fullfile(savePath, ['Electrode_' channelLabel '_Spectrogram.png']));
        close(fig1);  % Close the figure after saving
    end
    
    % Save mean spectra
    fig1 = figure(); 
    plot(f, 10*log10(squeeze(mean(S,1))));
    title('All Channels');
    xlabel('Frequency (Hz)')
    ylabel('Power (dB)')
    saveas(fig1, fullfile(savePath, 'AllElectrodes_Spectra.png'));
    
end
