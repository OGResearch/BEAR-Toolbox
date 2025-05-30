
% Starting a GUI application

function start()

    % Create user settings folder
    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    guiSettingsFolder = fullfile(guiFolder, "settings");
    userSettingsFolder = fullfile(".", "settings");
    gui.createFolder(userSettingsFolder);

    % Copy all *.json files from guiSettingsFolder to userSettingsFolder
    for fileName = ["dataSettings", "metaSettings", "estimatorSettings", "selection"] + ".json"
        copyfile(fullfile(guiSettingsFolder, fileName), fullfile(userSettingsFolder, fileName));
    end

    % Create user tables folder
    guiTablesFolder = fullfile(guiFolder, "tables");
    userTablesFolder = fullfile(".", "tables");
    gui.createFolder(userTablesFolder);

    % Copy all *.xlsx files from guiTablesFolder to userTablesFolder
    for fileName = ["ExactZeros", ] + ".xlsx"
        copyfile(fullfile(guiTablesFolder, fileName), fullfile(userTablesFolder, fileName));
    end

    htmlDir = gui.copyHTML();

    gui.populateMetaHTML();
    gui.populateDataHTML();
    gui.populateEstimatorSelectionHTML();
    gui.populateIdentificationSelectionHTML();

    % Open Matlab web browser
    indexPath = fullfile(htmlDir, 'index.html');
    web(indexPath);

end%
