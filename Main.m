% main.m
% Script to process data in the `files_to_process` folder and save results
% Contact: Sebastian Gallo, galloseb@mit.edu
% Date: Jan 13, 2025
% Must be ran while in peds_cp folder

clc; clear; close all;

% Define paths
projectDir = pwd;  % Current directory containing `peds_cp`
dataDir = fullfile(projectDir, 'files_to_process');
resultsDir = fullfile(projectDir, 'results');

% Create results directory if it doesn't exist
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% Parameters
peakFreq = 10;  % Frequency of interest (e.g., 10 Hz)
compareFreq = 5; % Optional comparison frequency (e.g., 5 Hz)

% Get list of .mat files in the data directory
dataFiles = dir(fullfile(dataDir, '*.mat'));

%% Single use case for Topoplot 
%% Directory Creation

% Simulate a single file from the data directory
fileName = 'Archive_1_CS_4_nobads_laplac_ds256_focus.mat';  % Test file
dataPath = fullfile(dataDir, fileName);

% Test parameters
peakFreq = 10;  % Frequency of interest (e.g., 10 Hz)
compareFreq = 5; % Optional comparison frequency (e.g., 5 Hz)

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
    savePath = fullfile(resultsDir, group, subjectID,'topoplot');
    
    % Create the save directory if it doesn't exist
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end

    % Generate the topoplot and save results
    try
        runPowerTopoplot(dataPath, savePath, peakFreq, compareFreq);
        fprintf('Successfully processed %s\n', fileName);
    catch ME
        fprintf('Error processing %s: %s\n', fileName, ME.message);
    end
end

fprintf('All files processed. Results saved in %s\n', resultsDir);
