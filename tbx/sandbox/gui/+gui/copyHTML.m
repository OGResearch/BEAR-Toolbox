
% Copy the content of mkdocs/site to html folder

function userDir = copyHTML()

    % Copy the content of mkdoc/site to html folder (keep the structure)
    % gui folder
    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    sourceDir = fullfile(guiFolder,"mkdocs", "site");
    targetDir = fullfile(guiFolder, "html");
    userDir = fullfile(pwd, "html");

    gui.createFolder(targetDir);
    gui.createFolder(userDir);

    % Get all files in the source directory
    files = dir(fullfile(sourceDir, "**", "*"));
    for k = 1:length(files)
        if ~files(k).isdir
            %
            % Get relative path
            relativePath = replace(files(k).folder, sourceDir, "");
            %
            % Create target folder if it doesn't exist
            targetFolder = fullfile(targetDir, relativePath);
            gui.createFolder(targetFolder);
            %
            % Create user folder if it doesn't exist
            userFolder = fullfile(userDir, relativePath);
            gui.createFolder(userFolder);
            %
            % Copy file
            copyfile(fullfile(files(k).folder, files(k).name), fullfile(targetFolder, files(k).name));
            copyfile(fullfile(files(k).folder, files(k).name), fullfile(userFolder, files(k).name));
        end
    end

    % Create a .gitkeep file in the target folder
    gitkeepFile = fullfile(targetDir, ".gitkeep");
    if ~exist(gitkeepFile, "file")
        fclose(fopen(gitkeepFile, "w"));
    end

end%

