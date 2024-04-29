function [datapath_out] = removeBadChannels(dataPath, outputFolderPath, channelsToRemove)

% FUNCTION DESCRIPTION: This function will remove channels and only take
% the first 64 channels from the HDR.labels since the rest is negligible.
% It also aligns the data with the indices of the updated HDR.labels and
% saves the data into the specified
% folder. It also presents the size of the HDR.label and data before and
% after channel removal in the command window as a double-check that the
% function is working in the manner in which we would expect it to. 
% Author: Daphne Toglia 4/2024
% Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;
    
    channel_fields = {'label','transducer','units','physicalMin',...
        'physicalMax','digitalMin','digitalMax','prefilter','samples',...
        'frequency'};
    
    % Define path for figure
    figurePath = fullfile(outputFolderPath, 'Figures');
    if ~exist(figurePath, 'dir')
        mkdir(figurePath);
    end


    % Print the original size of HDR.label and data
    fprintf('Original size of HDR.label: %d\n', length(HDR.label));
    fprintf('Original size of data: %d x %d\n', size(data, 1), size(data, 2));

    % Define channels to remove and remove them from the first 60 channels
    logicalIndicesToRemove = ismember(HDR.label, channelsToRemove);
    logicalIndicesToRemove(65:end) = 1;
    removedChannels = HDR.label(logicalIndicesToRemove)';
    fprintf('Removing channels: \n');
    fprintf('%s,', removedChannels{:});
    fprintf('\n');
    fprintf('Removing indices: \n');
    fprintf('%d,', find(logicalIndicesToRemove));
    fprintf('\n');
    
    % Create figures to show before/after removal
    fig = figure('position',[1, 929, 1090, 408]);
    subplot(1,2,1)
    imagesc(data(1:64,1:500))
    hold on
    scatter(250,find(logicalIndicesToRemove),30,'ro','filled')
    hold off
    title('Before Removing Channels')
    xlabel('Time (samples)')
    ylabel('Channel')
    subplot(1,2,2)
    imagesc(data(~logicalIndicesToRemove,1:500))
    title('After Removing Channels')
    xlabel('Time (samples)')
    ylabel('Channel')
    
    % Save the figure 
    saveas(fig, fullfile(figurePath, 'RemovedChannels.png'));
    
    for i=1:length(channel_fields)
        HDR.(channel_fields{i}) = HDR.(channel_fields{i})(~logicalIndicesToRemove);
    end
    data = data(~logicalIndicesToRemove,:);

    % Print the size of HDR.label and data after channel removal
    fprintf('Size of HDR.label after channel removal: %d\n', length(HDR.label));
    fprintf('Size of data after channel removal: %d x %d\n', size(data, 1), size(data, 2));

    % When saving, use the 'updatedDataPath' for the files
    fprintf('Saving... \n')
    [~,filename,ext] = fileparts(dataPath);
    datastruct.HDR = HDR;
    datastruct.data = data;
    datastruct.removedChannels = removedChannels;
    datapath_out = fullfile(outputFolderPath, [filename '_nobads' ext]);
    save(datapath_out, '-struct', 'datastruct', '-v7.3');
    fprintf('Done. \n')
end

