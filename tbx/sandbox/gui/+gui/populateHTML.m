% Copy the content of mkdocs/site to html folder
function targetDir = populateHTML()
    % Copy the content of mkdoc/site to html folder (keep the structure)
    % gui folder
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);
    sourceDir = fullfile(gui_folder,'mkdocs', 'site');
    targetDir = fullfile(gui_folder, 'html');
    
    if ~exist(targetDir, 'dir')
        mkdir(targetDir);
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
            % Copy file
            copyfile(fullfile(files(k).folder, files(k).name), fullfile(targetFolder, files(k).name));
        end
    end
    
    
    
end