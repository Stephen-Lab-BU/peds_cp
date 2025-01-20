function [] = runPowerTopoplot(dataPath, savePath, peakFreq, compareFreq)
   
    %FUNCTION DESCRIPTION: Function takes the downsampled-laplacian-referenced data 
    %and plots the power at frequency peakFreq as a topoplot
    % Author: Daphne Toglia 4/2024
    % Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;
    t = datastruct.t;
    Fs = HDR.frequency(1);
    
    if ~exist(savePath, 'dir'), mkdir(savePath); end
    
    chanlocs = struct('labels', HDR.label);
    chanlocs = pop_chanedit(chanlocs, 'lookup', 'standard-10-5-cap385.elp');

    winlen_s = length(t)/Fs;
    bandwidth_hz = 1;
    TW = winlen_s*bandwidth_hz/2;
    params.Fs = Fs;             % Sampling frequency
    params.tapers = [TW, min(2*TW-1,10)];        % Time-bandwidth product and the number of tapers [TW K]
    params.fpass = [0, 45];  % Frequency range of interest for focused spectrogram
    
    [S, f] = mtspectrumc(data', params);
    
    if exist('compareFreq','var')
        peakPower = 10*log10(S(find(f>=peakFreq,1),:))-10*log10(S(find(f>=compareFreq,1),:));
    else
        peakPower = 10*log10(S(find(f>=peakFreq,1),:));
    end

    identifier = regexp(savePath, 'CS_\d+|CN_\d+', 'match', 'once');
    
    fig1 = figure;  % Create a new figure for each channel's plot
    topoplot(peakPower, chanlocs, 'electrodes','labels');  
    colorbar;
    if exist('compareFreq','var')
        title(sprintf('Power at %d Hz relative to %d Hz for %s', peakFreq, compareFreq,identifier));
        saveas(fig1, fullfile(savePath, ['PowerTopoplot_' num2str(peakFreq) 'Hz_vs_' num2str(compareFreq) 'Hz_' identifier '.png']));
    else
        title(sprintf('Power at %d Hz for %s', peakFreq, identifier));
        saveas(fig1, fullfile(savePath, ['PowerTopoplot_' num2str(peakFreq) 'Hz_' identifier '.png']));
    end