
% Author: Daphne Toglia 4/2024
% Edited ES 5/2024

% This code relies on two packages (add them to path before running):
% Chronux: http://chronux.org/
% eeglab: https://sccn.ucsd.edu/eeglab/index.php

%% User defined variables (Change these)

% Path to subjects directory (to load data)
subjects_dir = '';

% Path to output directory (for preprocessed data and figures)
save_dir = '';

% Subject ID
subject = 'CN7';

% Bad channels for this subject
channelsToRemove = {'M1', 'M2', 'FT8', 'Fz', 'TP7', 'C4', 'F4', 'CP3', 'CP4', 'FC4'};

% Time in minutes where there is good data, for plotting spectrogram
startMinutes = 33;

%% Set up paths

dataPath = fullfile(subjects_dir,subject,['Archive_1_' subject '.mat']);
outputFolderPath= fullfile(save_dir,subject);

if ~exist(outputFolderPath, 'dir')
   mkdir(outputFolderPath)
end

%% STEP 1 : Remove bad channels

dataPath_nobads = removeBadChannels(dataPath, outputFolderPath, channelsToRemove);
% dataPath_nobads = fullfile(outputFolderPath, ['Archive_1_' subject '_nobads.mat']);

%% STEP 2: Laplacian Calculation on Data 

close all

% Define Laplacian Montage
[MontageChannels, Montage] = defineKayserMontage();

% Run laplacian reference
dataPath_laplac = laplacian_reference(dataPath_nobads, outputFolderPath, Montage);
% dataPath_laplac = fullfile(outputFolderPath, ['Archive_1_' subject '_nobads_laplac.mat']);

%% STEP 3: Downsample Laplacian-Transformed Data

close all

newFs = 256;  % Downsampling to 256 Hz
dataPath_ds = downsampleDataAndTimeaxis(dataPath_laplac, outputFolderPath, newFs);
% dataPath_ds = fullfile(outputFolderPath, ['Archive_1_' subject '_nobads_laplac_ds256.mat']);

%% STEP 4: Extract the 2 minutes of "good" data for downstream processing

close all

focusDurationMinutes = 2;
dataPath_focus = extractFocusSegment(dataPath_ds,outputFolderPath,startMinutes,focusDurationMinutes);
% dataPath_focus = fullfile(outputFolderPath, ['Archive_1_' subject '_nobads_laplac_ds256_focus.mat']);

%% STEP 5: Run spectrograms for every electrode and save the figures 

close all 

% Run spectrograms for full dataset
runSpectrograms(dataPath_ds, fullfile(outputFolderPath,'Figures','MTSpectrogramsFullSession'), false);

% Run spectrograms for focused dataset
runSpectrograms(dataPath_focus, fullfile(outputFolderPath,'Figures','MTSpectrogramsFocused'), true);

%% STEP 6: Pick a frequency and plot the power as a topoplot

close all

peakFreq = 9; % frequency of alpha peak in Hz
compareFreq = 7; % frequency to compare the alpha frequency to
runPowerTopoplot(dataPath_focus, fullfile(outputFolderPath,'Figures','MTSpectrogramsFocused'), peakFreq, compareFreq);
runPowerTopoplot(dataPath_focus, fullfile(outputFolderPath,'Figures','MTSpectrogramsFocused'), peakFreq);

