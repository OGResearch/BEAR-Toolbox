
function createUserFolders()

    % Create user settings folder
    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    guiSettingsFolder = fullfile(guiFolder, "settings");
    userSettingsFolder = fullfile(".", "settings");
    copyfile(guiSettingsFolder, userSettingsFolder);

    % % Copy all *.json files from guiSettingsFolder to userSettingsFolder
    % for fileName = ["dataSettings", "metaSettings", "estimatorSettings", "selection"] + ".json"
    %     copyfile(fullfile(guiSettingsFolder, fileName), fullfile(userSettingsFolder, fileName));
    % end

    % Create user tables folder
    guiTablesFolder = fullfile(guiFolder, "tables");
    userTablesFolder = fullfile(".", "tables");
    % gui.createFolder(userTablesFolder);
    copyfile(guiTablesFolder, userTablesFolder);

    % Copy all *.xlsx files from guiTablesFolder to userTablesFolder
    % for fileName = ["ExactZeros", ] + ".xlsx"
    %     copyfile(fullfile(guiTablesFolder, fileName), fullfile(userTablesFolder, fileName));
    % end

    guiHTMLFolder = fullfile(guiFolder, "html");
    userHTMLFolder = fullfile(".", "html");
    copyfile(guiHTMLFolder, userHTMLFolder);

end%

