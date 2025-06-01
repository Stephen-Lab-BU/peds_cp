classdef DropboxUtils
    methods(Static)

        function path = getDropboxBase()
            % Returns the base Dropbox directory (MIT Dropbox or Dropbox)
            homeDir = getenv('USERPROFILE');
            if isempty(homeDir)
                homeDir = getenv('HOME');
            end

            path = fullfile(homeDir, 'MIT Dropbox');
            if ~isfolder(path)
                path = fullfile(homeDir, 'Dropbox');
            end

            if ~isfolder(path)
                error('No Dropbox folder found in %s', homeDir);
            end
        end

        function listFiles(folder)
            % Lists all non-hidden files in the specified folder
            if ~isfolder(folder)
                error('Folder does not exist: %s', folder);
            end

            files = dir(folder);
            files = files(~ismember({files.name}, {'.', '..'}));

            disp('Files:');
            for i = 1:length(files)
                disp(files(i).name);
            end
        end

        function fullPath = getPreprocessedDataPath()
            % Returns the full path to the 'Preprocessed data' folder within Dropbox
            base = DropboxUtils.getDropboxBase();
            fullPath = DropboxUtils.findFolder(base, 'Preprocessed data');

            if isempty(fullPath)
                error('Could not find ''Preprocessed data'' inside Dropbox.');
            end
        end

        function fullPath = findFolder(baseDir, targetFolder)
            % Recursively searches for a folder named `targetFolder` starting at `baseDir`
            fullPath = '';
            folders = dir(baseDir);

            for i = 1:length(folders)
                name = folders(i).name;
                if folders(i).isdir && ~ismember(name, {'.', '..'})
                    currentPath = fullfile(baseDir, name);
                    if strcmp(name, targetFolder)
                        fullPath = currentPath;
                        return;
                    else
                        fullPath = DropboxUtils.findFolder(currentPath, targetFolder);
                        if ~isempty(fullPath)
                            return;
                        end
                    end
                end
            end
        end

    end
end
