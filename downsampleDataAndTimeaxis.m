function [datapath_out] = downsampleDataAndTimeaxis(dataPath, outputFolderPath, newFs)
    
    % FUNCTION DESCRIPTION: Downsamples the already modified, laplacian-referenced EEG data 
    % to a new sampling frequency (newFs) and plots the
    % original and downsampled signals for the first electrode in
    % HDR_updated.label_finalized. Plots figure demonstrating data from 
    % the first electrode before and after downsampling. Saves this data in main 'Data Folder' in
    % sub-folder called 'DownsampledLaplacianReferencedData'.
    % Author: Daphne Toglia 4/2024
    % Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;
    t = datastruct.t;
    originalFs = HDR.frequency(1);
    
    % Calculate the downsampling factor
    dsfactor = originalFs / newFs;

    % Downsample the data for each channel
    dsdata_laplac = resample(data', newFs, originalFs)';  % Transpose data for resample function

    % Calculate the downsampled time axis
    dst = downsample(t, dsfactor);  % Downsampled time axis
    
    % Assuming the first electrode in HDR_updated.label_finalized is what you want to plot
    firstElectrodeIndex = 1;

    % Plotting the first electrode before and after downsampling
    figure(1);
    plot(t, data(firstElectrodeIndex, :), 'b.-');     
    hold on
    plot(dst, dsdata_laplac(firstElectrodeIndex, :), 'r.-');  
    hold off
    legend('Original','Downsampled')
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Save the downsampled data and time axis in the sub-folder
    fprintf('Saving... \n')
    [~,filename,ext] = fileparts(dataPath);
    datastruct.data = dsdata_laplac;
    datastruct.HDR.frequency(:) = newFs;
    datastruct.t = dst;
    datapath_out = fullfile(outputFolderPath, [filename '_ds' num2str(newFs) ext]);
    save(datapath_out, '-struct', 'datastruct', '-v7.3');
    fprintf('Done. \n')
end
