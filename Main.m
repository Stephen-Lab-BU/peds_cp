% main.m
% Script to process data in the `files_to_process` folder and save results
% Contact: Sebastian Gallo, galloseb@mit.edu
% Date: Jan 13, 2025
% Must be ran while in peds_cp folder
% Must have path to chronux and eeg lab

clc; clear; close all;

% Define paths

projectDir = pwd;  % Current directory containing `peds_cp`
dataDir = DropboxUtils.getPreprocessedDataPath();
resultsDir = fullfile(projectDir, 'results');

% Create results directory if it doesn't exist
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% Get list of .mat files in the data directory
dataFiles = dir(fullfile(dataDir, '*.mat'));

%% Single use case for Topoplot 
%% Directory Creation

% Simulate a single file from the data directory
fileName = 'Archive_1_CS_4_nobads_laplac_ds256_focus.mat';  % Test file
dataPath = fullfile(dataDir, fileName);

% Test parameters
peakFreq = 13;  % Frequency of interest (e.g., 10 Hz)
compareFreq = 7; % Optional comparison frequency (e.g., 5 Hz)

fprintf('Processing file: %s\n', fileName);

% Determine if the file is a patient (CS) or control (CN)
if contains(fileName, '_CS_')
    group = 'patients';
    subjectID = regexp(fileName, 'CS_\d+', 'match', 'once');  % Extract CS_#
elseif contains(fileName, '_CN_')
    group = 'controls';
    subjectID = regexp(fileName, 'CN_\d+', 'match', 'once');  % Extract CN_#
else
    fprintf('Skipping file (unknown group): %s\n', fileName);
    return;
end

% Define the save path based on group and subject ID
savePath = fullfile(resultsDir, group, subjectID,'topoplot');

% Create the save directory if it doesn't exist
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

%% Topoplot creation
% Call the function to generate the topoplot

try
    runPowerTopoplot(dataPath, savePath, peakFreq, compareFreq);
    fprintf('Successfully processed %s\n', fileName);
catch ME
    fprintf('Error processing %s: %s\n', fileName, ME.message);
end

fprintf('Processing completed. Results saved in %s\n', savePath);

%% Section for processing all topoplot

% Parameters
peakFreq = 13;  % Frequency of interest (e.g., 13 Hz)
compareFreq = [7]; % Optional comparison frequency (set to [] if not used)

% Loop through each file and process
for i = 1:length(dataFiles)
    fprintf('Processing file %d of %d: %s\n', i, length(dataFiles), dataFiles(i).name);

    % Full path to the data file
    dataPath = fullfile(dataFiles(i).folder, dataFiles(i).name);
    fileName = dataFiles(i).name;  % Get the file name
    
    % Check if it's a patient (CS) or control (CN)
    if contains(fileName, '_CS_')
        group = 'patients';
        subjectID = regexp(fileName, 'CS_\d+', 'match', 'once');  % Extract CS_#
    elseif contains(fileName, '_CN_')
        group = 'controls';
        subjectID = regexp(fileName, 'CN_\d+', 'match', 'once');  % Extract CN_#
    else
        fprintf('Skipping file (unknown group): %s\n', fileName);
        continue;
    end

    % Define save path based on group and subject ID
    savePath = fullfile(resultsDir, group, subjectID, 'topoplot');
    
    % Create the save directory if it doesn't exist
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end

    % Determine if both `peakFreq` and `compareFreq` are used
    try
        if isempty(compareFreq)
            % Only peakFreq
            runPowerTopoplot(dataPath, savePath, peakFreq);
            fprintf('Processed %s with peakFreq only: %d Hz\n', fileName, peakFreq);
        else
            % Both peakFreq and compareFreq
            runPowerTopoplot(dataPath, savePath, peakFreq, compareFreq);
            fprintf('Processed %s with peakFreq: %d Hz and compareFreq: %d Hz\n', fileName, peakFreq, compareFreq);
        end
    catch ME
        fprintf('Error processing %s: %s\n', fileName, ME.message);
    end
end

fprintf('All files processed. Results saved in %s\n', resultsDir);

%% Section for spectrograms
% runSpectrograms(dataPath,savePath,true)

datastruct = load(dataPath);
HDR = datastruct.HDR;
data = datastruct.data;
t = datastruct.t;
Fs = HDR.frequency(1);

params.Fs = Fs;             % Sampling frequency
params.tapers = [2 3];      % Time-bandwidth product and number of tapers [TW K]
params.fpass = [0, 35];     % Frequency range of interest for focused spectrogram
movingwin = [2 1];          % Window length is 2s and step size is 1s for overlap

[S, t_spec, f] = mtspecgramc(data', movingwin, params);

idx = 2;
channelLabel = HDR.label{idx};

% Convert power to dB
S_dB = 10 * log10(S(:,:,idx));

% Compute color scale limits based on percentiles
lower_bound = prctile(S_dB(:), 5);   % 5th percentile instead of min()
upper_bound = prctile(S_dB(:), 95);  % 95th percentile instead of max()

% Print the clim values
fprintf('Automatic color limit settings:\n');
fprintf('Lower bound (5th percentile): %.2f dB\n', lower_bound);
fprintf('Upper bound (95th percentile): %.2f dB\n', upper_bound);

% Plot spectrogram with optimized clim
fig1 = figure('visible','on','position',[1, 929, 1090, 408]);  
subplot(1,2,1)
imagesc(t_spec+t(1), f, S_dB');  
axis xy;
colormap('jet');
ylabel(colorbar, 'Power (dB)');
clim([lower_bound, upper_bound]);  % Apply optimized clim
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title(['Electrode ' channelLabel]);


% Plot mean power spectrum
subplot(1,2,2)
plot(f, mean(S_dB,1));
xlabel('Frequency (Hz)')
ylabel('Power (dB)')

%% Plotted Power Metrics for Data for 1 index (Channel)

idx = 2;

% Compute total power over time
total_power_time = sum(S(:,:,idx), 2); % Sum over frequency dimension
total_power_time_dB = 10 * log10(total_power_time); % Convert to dB

% Compute total power over frequency
total_power_freq = sum(S(:,:,idx), 1); % Sum over time dimension
total_power_freq_dB = 10 * log10(total_power_freq); % Convert to dB

% Plot total power over time in dB
figure;
plot(t_spec+t(1), total_power_time_dB, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Total Power (dB)');
title(['Total Power Over Time (dB) - Electrode ' channelLabel]);
grid on;

% Plot total power over frequency in dB
figure;
plot(f, total_power_freq_dB, 'LineWidth', 2);
xlabel('Frequency (Hz)');
ylabel('Total Power (dB)');
title(['Total Power Over Frequency (dB) - Electrode ' channelLabel]);
grid on;

%% Format 1 plotting multiple spectrograms
num_channels = 7;  % Number of channels to plot
channel_indices = 1:num_channels;  % Select the first 7 channels

fig1 = figure('visible', 'on', 'position', [100, 100, 1400, 500]);  

for i = 1:num_channels
    idx = channel_indices(i);
    S_dB = 10 * log10(S(:,:,idx));  % Convert power to dB for current channel

    subplot(1, num_channels, i);  % Arrange spectrograms horizontally
    imagesc(t_spec+t(1), f, S_dB');  
    axis xy;  
    colormap('jet');  
    caxis([lower_bound, upper_bound]);  % Apply the same color scale to all
    
    % Label frequency axis on the first subplot only
    if i == 1
        ylabel('Frequency (Hz)');
    else
        yticklabels([]);  % Remove y-axis labels for all but the first plot
    end

    % Label time axis only on the last subplot
    if i == num_channels
%         xlabel('Time (s)');
        xticklabels([]);
        print('no label')
    else
        xticklabels([]);  % Remove x-axis labels to reduce clutter
    end

    % Title with channel name
    channelLabel = HDR.label{idx};
    title(channelLabel, 'FontSize', 10, 'FontWeight', 'bold');
end

% Add a single colorbar to the right side of the figure
cb = colorbar;
cb.Position = [0.92 0.2 0.02 0.6]; % Adjust position for all subplots
ylabel(cb, 'Power (dB)');


%% Format 2 plotting multiple spectrograms
num_channels = 7;  % Number of channels to stitch
channel_indices = 1:num_channels;  % Select the first 7 channels

fig1 = figure('visible', 'on', 'position', [100, 100, 1400, 500]);

% Initialize stitched spectrogram
S_dB_stitched = [];  % Concatenated spectrogram matrix
channel_boundaries = []; % Store y-axis breakpoints for labeling

% Concatenate all channels along the time dimension (1st dimension)
for i = 1:num_channels
    idx = channel_indices(i);
    S_dB = 10 * log10(S(:,:,idx));  % Convert power to dB for current channel

    % Concatenate along the first dimension (time)
    S_dB_stitched = [S_dB_stitched; S_dB];  

    % Store boundary location for labels and dividers
    channel_boundaries = [channel_boundaries, size(S_dB_stitched,1)];
end

% Define new time axis (stacked time points)
t_stitched = 1:size(S_dB_stitched,1); 

% Plot the stitched spectrogram
imagesc(t_stitched, f, S_dB_stitched');  
axis xy;  
colormap('jet');  
caxis([lower_bound, upper_bound]);  % Apply optimized color scale

% Label frequency axis (y-axis)
ylabel('Frequency (Hz)');

% Remove x-axis labels (no explicit time axis)
xticklabels([]);

% Draw horizontal lines (`yline`) to separate channels and add labels
hold on;
for i = 1:num_channels
    yline(channel_boundaries(i), 'w', 'LineWidth', 2);  % White separator
    text(-10, channel_boundaries(i) - size(S_dB,1)/2, ...
        HDR.label{channel_indices(i)}, 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'w', ...
        'HorizontalAlignment', 'right', 'Rotation', 90);  % Rotate text vertically
end
hold off;

% Add a single colorbar to the right
cb = colorbar;
cb.Position = [0.92 0.2 0.02 0.6]; % Adjust position for all subplots
ylabel(cb, 'Power (dB)');

%% Multispectrogram on Scalp
multiSpectrogramScalp_2(dataPath, savePath, true);
