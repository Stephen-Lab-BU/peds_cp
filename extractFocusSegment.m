function [datapath_out] = extractFocusSegment(dataPath, outputFolderPath, startMinutes, focusDurationMinutes)
    
    % FUNCTION DESCRIPTION: extracts a segment of data for focused
    % analysis. Starts at 'startMinutes' and the length of the segment is
    % 'focusMinutes' 
    % Edited ES 5/2024

    fprintf('Loading Data... \n')
    datastruct = load(dataPath);
    HDR = datastruct.HDR;
    data = datastruct.data;
    t = datastruct.t;
    Fs = HDR.frequency(1);
    
    startTimeSec = startMinutes * 60; % Convert to seconds
    if startTimeSec >= t(end)
        error(['Start time (' num2str(startMinutes) ' minutes) exceeds total recording length.']);
    end

    startTimeIdx = find(t>startTimeSec,1,'first'); 
    endTimeIdx = startTimeIdx + round(focusDurationMinutes * 60 * Fs) - 1;  
    if endTimeIdx > length(t)
        error('Focus window exceeds data length.');
    end

    dataSegment = data(:, startTimeIdx:endTimeIdx);
    tSegment = t(:,startTimeIdx:endTimeIdx);
    
    % Save the downsampled data and time axis in the sub-folder
    fprintf('Saving... \n')
    [~,filename,ext] = fileparts(dataPath);
    datastruct.data = dataSegment;
    datastruct.t = tSegment;
    datastruct.focusStartMinutes = startMinutes;
    datastruct.focusDurationMinutes = focusDurationMinutes;
    datapath_out = fullfile(outputFolderPath, [filename '_focus' ext]);
    save(datapath_out, '-struct', 'datastruct', '-v7.3');
    fprintf('Done. \n')
end
