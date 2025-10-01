
function recreateLocalFolders()

    % Create local settings folder
    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    guiSettingsFolder = fullfile(guiFolder, "settings");
    localSettingsFolder = fullfile(".", "settings");
    copyfile(guiSettingsFolder, localSettingsFolder);

    % % Copy all *.json files from guiSettingsFolder to localSettingsFolder
    % for fileName = ["dataSettings", "metaSettings", "estimatorSettings", "selection"] + ".json"
    %     copyfile(fullfile(guiSettingsFolder, fileName), fullfile(localSettingsFolder, fileName));
    % end

    % Create local tables folder
    guiTablesFolder = fullfile(guiFolder, "tables");
    localTablesFolder = fullfile(".", "tables");
    % gui.createFolder(localTablesFolder);
    copyfile(guiTablesFolder, localTablesFolder);

    % Copy all *.xlsx files from guiTablesFolder to localTablesFolder
    % for fileName = ["ExactZeros", ] + ".xlsx"
    %     copyfile(fullfile(guiTablesFolder, fileName), fullfile(localTablesFolder, fileName));
    % end

    guiHTMLFolder = fullfile(guiFolder, "html");
    localHTMLFolder = fullfile(".", "html");
    copyfile(guiHTMLFolder, localHTMLFolder);

end%

