function multiSpectrogramScalp(dataPath, savePath, blnFocused)
% multiSpectrogramScalp
%  - Loads EEG data (assumed preprocessed)
%  - Computes multi-taper spectrograms with Chronux
%  - Selects a subset of channels for plotting
%  - Arranges each channel's spectrogram on a circular scalp layout

    %% 1) Load Data
    fprintf('Loading Data from %s...\n', dataPath);
    datastruct = load(dataPath);
    HDR = datastruct.HDR;        
    data = datastruct.data;      
    t    = datastruct.t;         
    Fs   = HDR.frequency(1);     

    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end

    %% 2) Define Chronux spectrogram parameters
    if blnFocused
        params.Fs = Fs;
        params.tapers = [2 3];      
        params.fpass = [0 25];      
        movingwin = [2 1];          
    else
        params.Fs = Fs;
        params.tapers = [5 8];      
        movingwin = [10 5];         
    end

    % Compute spectrogram using Chronux
    fprintf('Computing multi-taper spectrograms...\n');
    [S, t_spec, f] = mtspecgramc(data', movingwin, params);

    %% 3) Load channel locations
    chanlocs = struct('labels','');
    chanlocs = repmat(chanlocs, 1, numel(HDR.label));
    for c = 1:numel(HDR.label)
        chanlocs(c).labels = HDR.label{c};
    end
    chanlocs = pop_chanedit(chanlocs, 'lookup', 'standard-10-5-cap385.elp');

    %% 4) Select a subset of channels
    selectedChannels = {
        'Fp1','Fp2', ...
        'F7','F3','Fz','F4','F8', ...
        'T7','C3','Cz','C4','T8', ...
        'P7','P3','Pz','P4','P8', ...
        'O1','O2'
    };

    [~, chanIdx] = ismember(selectedChannels, HDR.label);
    if any(chanIdx == 0)
        error('Some selectedChannels were not found in HDR.label. Check spelling.');
    end

    Ssub = S(:,:,chanIdx);

    %% 5) Convert S to dB and compute global color range
    Sdb = 10*log10(Ssub);
    globalMin = min(Sdb(:));
    globalMax = max(Sdb(:));

%% 6) Create the scalp figure (using separate axes for the circle)
    fprintf('Creating scalp layout figure...\n');
    hFig = figure('Name','Multi-channel Spectrograms','Position',[100,100,900,900]);
    
    % -- Create a main axes for the scalp circle:
    axMain = axes('Parent', hFig, ...
                  'Units', 'normalized', ...
                  'Position', [0 0 1 1]);  % covers the entire figure
    hold(axMain, 'on');
    axis(axMain, 'off');      % hide ticks
    axis(axMain, 'equal');    % preserve the circle aspect ratio
    axis(axMain, [0 1 0 1]);  % lock main axes to [0..1, 0..1] so it never auto-rescales
    
    scalpRadius = 0.35;
    
    % Draw the scalp circle in the main axes
    thetaCirc = linspace(0, 2*pi, 201);
    rx = cos(thetaCirc);
    ry = sin(thetaCirc);
    plot(axMain, rx*scalpRadius + 0.5, ry*scalpRadius + 0.5, 'k', 'LineWidth', 2);
    
    % Dimensions for each mini-spectrogram axis (in normalized figure coords)
    axWidth  = 0.1;
    axHeight = 0.1;
    
    % Get maximum radius (so that EEGLAB's radii map nicely)
    maxRadius = max([chanlocs.radius]);
    
    % Store coordinates for later (optional)
    coords = zeros(length(selectedChannels), 2);
    
    % Loop through selected channels
    for i = 1:length(selectedChannels)
        chName = selectedChannels{i};
        idx    = chanIdx(i);
    
        % Ensure valid theta/radius
        if isnan(chanlocs(idx).theta) || isnan(chanlocs(idx).radius) || ...
           isempty(chanlocs(idx).theta) || isempty(chanlocs(idx).radius)
            fprintf('Skipping channel %s (invalid location)\n', chName);
            continue;
        end
    
        % Get theta (radians) and normalized radius
        thisTheta  = chanlocs(idx).theta * (pi/180);
        radiusNorm = chanlocs(idx).radius / maxRadius;
    
        % EEGLAB typically has 0° at the nose (front); rotate by -90° if needed
        thisTheta = thisTheta - pi/2;
    
        % Convert to Cartesian (center at (0.5,0.5))
        xPlot = 0.5 + radiusNorm * scalpRadius * cos(thisTheta);
        yPlot = 0.5 - radiusNorm * scalpRadius * sin(thisTheta); 
        coords(i,:) = [xPlot, yPlot];
    
        % Position of the mini-axes (center around xPlot,yPlot)
        posX = xPlot - axWidth/2;
        posY = yPlot - axHeight/2;
    
        % Create a sub-axes for the spectrogram
        axSpec = axes('Parent', hFig, ...
                      'Units','normalized', ...
                      'Position',[posX, posY, axWidth, axHeight]);
    
        % Plot the spectrogram in this sub-axes
        imagesc(axSpec, t_spec, f, Sdb(:,:,i)');
        axis(axSpec, 'xy');
        set(axSpec, 'XTick', [], 'YTick', []);    % hide ticks
        caxis(axSpec, [globalMin, globalMax]);    % set global color limits
        title(axSpec, chName, 'FontSize', 8);
    end
    
    % Add a single colorbar
    colormap(hFig, 'jet');
    hCb = colorbar('Position',[0.92,0.3,0.02,0.4]);
    hCb.Label.String = 'Power (dB)';
    
    % Save figure
    fprintf('Saving figure to %s\n', savePath);
    if ~exist(savePath,'dir'), mkdir(savePath); end
    savefig(hFig, fullfile(savePath,'ScalpSpectrograms_24Ch.fig'));
    saveas(hFig, fullfile(savePath,'ScalpSpectrograms_24Ch.png'));
    

    
    %% 7) Visualize Spectrogram Placement
    
%     figure;
%     scatter(coords(:,1), coords(:,2), 'filled'); % Scatter plot of all positions
%     hold on;
%     
%     % Overlay expected circle
%     theta = linspace(0, 2*pi, 100);
%     plot(0.5 + scalpRadius*cos(theta), 0.5 + scalpRadius*sin(theta), 'r', 'LineWidth', 2);
%     
%     axis equal;
%     title('Spectrogram Arrangement');
%     xlabel('X Position'); ylabel('Y Position');
%     legend('Spectrogram Centers', 'Expected Circle');



end

