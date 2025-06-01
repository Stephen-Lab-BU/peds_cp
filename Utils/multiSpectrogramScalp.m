function multiSpectrogramScalp(dataPath, savePath, blnFocused)
% multiSpectrogramScalp
%  - Loads EEG data (assumed preprocessed)
%  - Computes multi-taper spectrograms with Chronux
%  - Selects a subset of channels for plotting
%  - Arranges each channel's spectrogram on a scalp layout using chanlocs
%
%  dataPath  : path to .mat file containing data, HDR, and time vector t
%  savePath  : directory where outputs (.fig, .png) are saved
%  blnFocused: boolean; if true => uses "focused" spectrogram parameters

    %% 1) Load Data
    fprintf('Loading Data from %s...\n', dataPath);
    datastruct = load(dataPath);
    HDR = datastruct.HDR;        % .label should be your channel names
    data = datastruct.data;      % [channels x time]
    t    = datastruct.t;         % time vector
    Fs   = HDR.frequency(1);     % sampling frequency

    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end

    %% 2) Define Chronux spectrogram parameters
    if blnFocused
        % For "focused" analysis (shorter segments, smaller bandwidth)
        params.Fs = Fs;
        params.tapers = [2 3];      % [TW K] => time-bandwidth product, # of tapers
        params.fpass = [0 25];      % frequency range
        movingwin = [2 1];          % 4s window, 1s step
    else
        % For "full" spectrogram (longer segments, bigger bandwidth)
        params.Fs = Fs;
        params.tapers = [5 8];      % e.g., [TW K]
        movingwin = [10 5];         % 10s window, 5s step
    end

    % Compute spectrogram using Chronux (data' => [time x channels])
    fprintf('Computing multi-taper spectrograms...\n');
    [S, t_spec, f] = mtspecgramc(data', movingwin, params);
    % S is [timeBins x freqBins x channels]
    % t_spec is the time axis for each window
    % f is frequency axis

    %% 3) Create chanlocs for scalp plotting
    % We'll create a chanlocs struct from your HDR.label, then do a lookup.
    chanlocs = struct('labels','');
    chanlocs = repmat(chanlocs, 1, numel(HDR.label));
    % Fill each element with one channel label
    for c = 1:numel(HDR.label)
        chanlocs(c).labels = HDR.label{c};
    end
    % Now call pop_chanedit on the array of structs
    chanlocs = pop_chanedit(chanlocs, 'lookup', 'standard-10-5-cap385.elp');

    %% 4) Select a subset of channels
    selectedChannels = {
        'Fp1','Fpz','Fp2', ...
        'F7','F3','Fz','F4','F8', ...
        'C3','Cz','C4','T7','T8', ...
        'P3','Pz','P4','P7','P8', ...
        'O1','Oz','O2',
    };

    % Get indices of these channels in HDR.label
    [~, chanIdx] = ismember(selectedChannels, HDR.label);
    if any(chanIdx == 0)
        error('Some selectedChannels were not found in HDR.label. Check spelling.');
    end

    % Extract only the selected channels from S
    Ssub = S(:,:,chanIdx);

    %% 5) Convert S to dB and compute global color range
    Sdb = 10*log10(Ssub);  % [timeBins x freqBins x selectedChannels]
    globalMin = min(Sdb(:));
    globalMax = max(Sdb(:));

    %% 6) Create the scalp figure
    fprintf('Creating scalp layout figure...\n');
    hFig = figure('Name','Multi-channel Spectrograms','Position',[100,100,1200,900]);
    hold on;
    axis off; axis equal;

    %%% NEW SECTION: Normalize coordinates so everything appears on the scalp %%%
    allX = [chanlocs.X];
    allY = [chanlocs.Y];
    maxCoord = max(abs([allX, allY]));  % e.g., ~85 for some electrodes
    scalpRadius = 0.4;                 % how large the scalp is in [0..1] figure coords

    % OPTIONAL: draw a circle to represent the scalp boundary
    rectangle('Position',[0.5 - scalpRadius, 0.5 - scalpRadius, 2*scalpRadius, 2*scalpRadius], ...
              'Curvature',1,'EdgeColor','k','LineWidth',1);

    % Axes size for each mini-spectrogram
    axWidth  = 0.07;
    axHeight = 0.07;

    % Loop through selected channels
    for i = 1:length(selectedChannels)
        chName = selectedChannels{i};
        idx    = chanIdx(i);

        xLoc   = chanlocs(idx).X;
        yLoc   = chanlocs(idx).Y;

        % 1) Normalize (X, Y) => [-1 .. +1]
        xNorm = xLoc / maxCoord;
        yNorm = yLoc / maxCoord;

        %1.5) Rotate 90 deg CCW:
 
        tempX = xNorm;
        xNorm = -yNorm;
        yNorm = tempX;

        % 2) Shift to [0.5, 0.5] and scale by scalpRadius
        xPlot = 0.5 + xNorm * scalpRadius;
        yPlot = 0.5 + yNorm * scalpRadius;

        % 3) Position the mini-axes
        posX = xPlot - axWidth/2;
        posY = yPlot - axHeight/2;
        ax   = axes('Parent',hFig,'Position',[posX, posY, axWidth, axHeight]);

        % Plot the spectrogram for this channel
        imagesc(ax, t_spec, f, Sdb(:,:,i)');
        axis xy; 
        set(ax,'XTick',[],'YTick',[]); % no axis ticks
        caxis(ax,[globalMin, globalMax]);  % consistent color range

        % Title with channel name
        title(chName,'FontSize',8);
    end

    % Add one global colorbar on the right side
    colormap('jet');
    hCb = colorbar('Position',[0.92,0.3,0.02,0.4]);
    hCb.Label.String = 'Power (dB)';

    % Save figure
    fprintf('Saving figure to %s\n', savePath);
    if ~exist(savePath,'dir'), mkdir(savePath); end
    savefig(hFig, fullfile(savePath,'ScalpSpectrograms_24Ch.fig'));
    saveas(hFig, fullfile(savePath,'ScalpSpectrograms_24Ch.png'));

    fprintf('Done! Check your saved figure to see if the layout is acceptable.\n');
end
