% Copy the content of mkdocs/site to html folder
function userDir = populateHTML()
    % Copy the content of mkdoc/site to html folder (keep the structure)
    % gui folder
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);
    sourceDir = fullfile(gui_folder,'mkdocs', 'site');
    targetDir = fullfile(gui_folder, 'html');
    userDir = fullfile(pwd, 'html');
    
    if ~exist(targetDir, 'dir')
        mkdir(targetDir);
    end
    if ~exist(userDir, 'dir')
        mkdir(userDir);
    end
    
    % Get all files in the source directory
    files = dir(fullfile(sourceDir, '**', '*'));
    for k = 1:length(files)
        if ~files(k).isdir
            % Get relative path
            relativePath = strrep(files(k).folder, sourceDir, '');
            % Create target folder if it doesn't exist
            targetFolder = fullfile(targetDir, relativePath);
            if ~exist(targetFolder, 'dir')
                mkdir(targetFolder);
            end
            % Create user folder if it doesn't exist
            userFolder = fullfile(userDir, relativePath);
            if ~exist(userFolder, 'dir')
                mkdir(userFolder);
            end
            % Copy file
            copyfile(fullfile(files(k).folder, files(k).name), fullfile(targetFolder, files(k).name));
            copyfile(fullfile(files(k).folder, files(k).name), fullfile(userFolder, files(k).name));
        end
    end
    
    % Create a .gitkeep file in the target folder
    gitkeepFile = fullfile(targetDir, '.gitkeep');
    if ~exist(gitkeepFile, 'file')
        fclose(fopen(gitkeepFile, 'w'));
    end
    
    
end