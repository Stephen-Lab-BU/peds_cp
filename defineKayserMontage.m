function [MontageChannels, Montage] = defineKayserMontage()
%FUNCTION DESCRIPTION: Defines electrodes and electrode neighbors from the
%Kayser paper as our montage reference.
%Paper:https://www.sciencedirect.com/science/article/pii/S0167876015001609
% Author: Daphne Toglia 5/2024
% Edited ES 5/2024

% Define all 66 electrodes
    MontageChannels = {'Fpz', 'AFz', 'Fz', 'FCz', 'Cz', 'CPz', 'Pz', 'POz', 'Oz', 'Iz', 'Fp1', 'AF3', 'F1', 'FC1', 'CP1', 'P1', 'F3', 'FC3', 'C3', 'CP3', 'P3', 'PO3', 'O1', 'AF7', 'F7', 'FT7', 'T7', 'TP9', 'P9', 'F5', 'FC5', 'C5', 'CP5', 'P5', 'PO7', 'TP7', 'P7', 'Fp2', 'AF4', 'F4', 'FC4', 'C4', 'CP4', 'P4', 'PO4', 'O2', 'F2', 'FC2', 'C2', 'CP2', 'P2', 'AF8', 'F6', 'FC6', 'C6', 'CP6', 'P6', 'PO8', 'F8', 'T8', 'TP8','P10', 'FT8','C1','P8','TP10'};
    % Initialize a containers.Map object to store electrode neighbors
    Montage = containers.Map();
    % Define electrode neighbors based on the referenced paper
    Montage('Fpz') = {'Fp1', 'Fp2', 'AFz', 'AF3','AF4'}; %5 neighbors
    Montage('O1') = {'PO3', 'PO7', 'Iz', 'Oz', 'POz'}; %5 neighbors
    Montage('O2') = {'PO8', 'Oz', 'POz', 'Iz','PO4'}; %5 neighbors
    Montage('AF3') = {'AFz', 'F1', 'F3', 'AF7'};
    Montage('Iz') = {'O2', 'Oz', 'O1'}; %3 neighbors
    Montage('AFz') = {'Fpz', 'AF4', 'AF3', 'F2'};
    Montage('AF4') = {'AF8', 'AFz', 'F4', 'Fp2'};
    Montage('AF7') = {'Fp1', 'AF3', 'F5', 'F7'};
    Montage('AF8') = {'Fp2', 'AF4', 'F8', 'F6'};
    Montage('C1') = {'FC1', 'CP1', 'C3', 'Cz'};
    Montage('AFz') = {'Fpz', 'AF4', 'AF3', 'F2'};
    Montage('C2') = {'C4', 'Cz', 'CP2', 'FC2'};
    Montage('C3') = {'FC3', 'C1', 'C5', 'CP3'};
    Montage('C4') = {'C6', 'C2', 'FC4', 'CP4'};
    Montage('C5') = {'C3', 'T7', 'FC5', 'CP5'};
    Montage('C6') = {'T8', 'C4', 'CP6', 'FC6'};
    Montage('CP1') = {'CP2', 'CP3', 'C1', 'P1'};
    Montage('CP2') = {'CP4', 'CPz', 'C2', 'P2'};
    Montage('CP3') = {'CP1', 'CP5', 'C3', 'P3'};
    Montage('CP4') = {'CP6', 'CP2', 'C4', 'P4'};
    Montage('CP5') = {'CP3', 'C5', 'TP7', 'P5'};
    Montage('CP6') = {'TP8', 'CP4', 'P6', 'C6'};
    Montage('CPz') = {'Cz', 'CP2', 'CP1', 'Pz'};
    Montage('Cz') = {'FCz', 'C1', 'C2', 'CPz'};
    Montage('F1') = {'Fz', 'F3', 'FC1', 'AF3'};
    Montage('F2') = {'AF4', 'F4', 'FC2', 'Fz'};
    Montage('F3') = {'F1', 'F5', 'AF3', 'FC3'};
    Montage('F4') = {'F6', 'F2', 'AF4', 'FC4'};
    Montage('F5') = {'F3', 'F7', 'AF7', 'FC5'};
    Montage('F6') = {'F8', 'FC6', 'F4', 'AF8'};
    Montage('F7') = {'AF7', 'F5', 'FC5', 'FT7'};
    Montage('F8') = {'FT8', 'F6', 'AF8', 'FC6'};
    Montage('FC1') = {'FCz', 'FC3', 'F1', 'C1'};
    Montage('FC2') = {'FC4', 'FCz', 'C2', 'F2'};
    Montage('FC3') = {'FC1', 'FC5', 'C3', 'F3'};
    Montage('FC4') = {'FC6', 'FC2', 'F4', 'C4'};
    Montage('FC5') = {'F5', 'FC3', 'FT7', 'C5'};
    Montage('FC6') = {'FT8', 'F6', 'C6', 'FC4'};
    Montage('FCz') = {'Fz', 'FC2', 'FC1', 'Cz'};
    Montage('Fp1') = {'Fpz', 'AF7', 'AF3', 'AFz'};
    Montage('Fp2') = {'AF4', 'AF8', 'Fpz', 'AFz'};
    Montage('Fpz') = {'Fp1', 'Fp2', 'AFz', 'AF3', 'AF4'}; %5 neighbors
    Montage('FT7') = {'FC5', 'F5', 'F7', 'T7'};
    Montage('FT8') = {'T8', 'F8', 'FC6', 'F6'};
    Montage('Fz') = {'AFz', 'F1', 'F2', 'FCz'};
    Montage('Oz') = {'O2', 'POz', 'O1', 'Iz'};
    Montage('P1') = {'Pz', 'P3', 'CP1', 'PO3'};
    Montage('P10') = {'P8', 'TP8', 'PO8', 'TP10'};
    Montage('P2') = {'P4', 'Pz', 'CP2', 'PO4'};
    Montage('P3') = {'P1', 'P5', 'CP3', 'PO3'};
    Montage('P4') = {'P2', 'P6', 'CP4', 'PO4'};
    Montage('P5') = {'P3', 'P7', 'CP5', 'PO5'}; % edited ES for PO5 4/2024
    Montage('P6') = {'P8', 'P4', 'CP6', 'PO6'}; % edited ES for PO6  4/2024
    Montage('P7') = {'P5', 'PO7', 'P9', 'TP9'};
    Montage('P9') = {'P7', 'TP9', 'TP7', 'PO7'};
    Montage('PO3') = {'P1', 'P3', 'O1', 'PO5'}; % edited ES for PO5 4/2024
    Montage('PO4') = {'PO6', 'O2', 'POz', 'P4'}; % edited ES for PO6 4/2024
    Montage('PO5') = {'PO7','PO3','P5','O1'}; % added manually ES 4/2024
    Montage('PO6') = {'PO4','PO8','P6','O2'}; % added manually ES 4/2024
    Montage('PO7') = {'P5', 'P7', 'O1', 'PO5'}; % edited ES for PO5 4/2024
    Montage('PO8') = {'P8', 'P6', 'PO6', 'O2'}; % edited ES for PO6 4/2024
    Montage('POz') = {'Pz', 'PO4', 'Oz', 'PO3'};
    Montage('Pz') = {'P2', 'Cpz', 'P1', 'POz'};
    Montage('T7') = {'FT7', 'C5', 'TP7', 'TP9'};
    Montage('T8') = {'TP10', 'FT8', 'C6', 'TP8'};
    Montage('TP7') = {'CP5', 'TP9', 'P7', 'T7'};
    Montage('TP8') = {'TP10', 'T8', 'P8', 'CP6'};
    Montage('TP9') = {'T7', 'TP7', 'P9', 'P7'};
    Montage('TP10') = {'TP8', 'T8', 'P10', 'PO8'};
    Montage('P8') = {'TP8', 'P10', 'P6', 'PO8'};
end