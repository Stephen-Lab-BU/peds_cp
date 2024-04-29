function [datapath_out] = laplacian_reference(dataPath, outputFolderPath, Montage)

    %FUNCTION DESCRIPTION: This function conducts laplacian calculations on
    %our updated HDR.labels & data, this conducts a check for if and when a
    %channel/electrode has an insufficient amount of channel neighbors and
    %will proceed to output an error warning with the specific channels
    %with insufficient channel neighbors. Might consider adjusting
    %threshold but for now it is less than 3 (< 3). This function will also
    %plot the first electrode pre and post-laplacian reference and will
    %also plot the channels with insufficient neighbors. All of this will
    %be saved onto the specified folder.
    % Author: Daphne Toglia 4/2024
    % Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;

    % Ensure the number of data rows matches the number of HDR
    assert(size(data, 1) == length(HDR.label), 'Mismatch between data rows and HDR_updated.label_finalized.');
    
    % Initialize the output matrix
    nChannels = length(HDR.label);
    nTimepoints = size(data, 2);
    data_laplac = zeros(nChannels, nTimepoints);

    % Initialize an array to keep track of valid channels
    validChannels = true(1, nChannels);
    skippedChannels = {};
    tooFewNeighbors = {};
    
    % Define the path for insufficient neighbor channel plots within
    insuffNeighborPlotsPath = fullfile(outputFolderPath, 'Figures', 'InsufficientNeighborPlots');
    if ~exist(insuffNeighborPlotsPath, 'dir')
        mkdir(insuffNeighborPlotsPath);
    end

    % Iterate over all channels in HDR
    for i = 1:nChannels
        channel = HDR.label{i};

        % Verify the current channel is defined in the montage
        if ~isKey(Montage, channel)
            warning('Channel %s not found in montage. Skipping this channel.', channel);
            validChannels(i) = false;
            skippedChannels{end+1} = channel;
            continue;
        else
            fprintf('Running Laplacian for Channel %s \n', channel);
        end

        % Retrieve neighbors for the current channel from the montage
        neighbors = Montage(channel);

        % Find indices of neighbors in HDR
        neighbor_inds = find(ismember(HDR.label, neighbors));

        % Ensure there are enough neighbors for meaningful Laplacian calculation
        if length(neighbor_inds) < 3
            warning('Only %d neighbors for channel %s. Laplacian calculation may be inaccurate.', length(neighbor_inds), channel);
            validChannels(i) = false;
            tooFewNeighbors{end+1} = {channel,length(neighbor_inds)};

            % Create a figure for the insufficient neighbors warning
            fig = figure('visible', 'off');
            plot(datastruct.t,data(i, :));
            title(['Channel ' channel ' - Only ' num2str(length(neighbor_inds)) ' Neighbors']);
            xlabel('Time Points');
            ylabel('Amplitude');

            % Save the figure 
            saveas(fig, fullfile(insuffNeighborPlotsPath, ['Channel_' channel '_InsuffNeighbors.png']));
            close(fig);
            
            if isempty(neighbor_inds)
                continue;
            end
        end

        % Calculate Laplacian: data for the channel minus mean of its neighbors
        data_laplac(i, :) = data(i, :) - mean(data(neighbor_inds, :), 1);
    end
    
    figure(1)
    plot(datastruct.t,data(1, :),datastruct.t,data_laplac(1, :));
    legend('Before Laplac','After Laplac')
    title('Channel 1');
    xlabel('Time Points');
    ylabel('Amplitude');
    
    % Save the Laplacian-referenced data and valid channels into the 'AllLaplacianReferencedData' folder
    fprintf('Saving... \n')
    [~,filename,ext] = fileparts(dataPath);
    datastruct.data = data_laplac;
    datastruct.valid_channels = validChannels;
    datastruct.skipped_channels = skippedChannels;
    datastruct.tooFewNeighbors = tooFewNeighbors;
    datapath_out = fullfile(outputFolderPath, [filename '_laplac' ext]);
    save(datapath_out, '-struct', 'datastruct', '-v7.3');
    fprintf('Done. \n')
end
