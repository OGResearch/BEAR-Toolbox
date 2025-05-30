
% Starting a GUI application

function start()

    % Copy selection.json
    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    guiSettingsFolder = fullfile(guiFolder, "settings");
    userSettingsFolder = fullfile(".", "settings");
    gui.createFolder(userSettingsFolder);
    copyfile(fullfile(guiSettingsFolder, "selection.json"), fullfile(userSettingsFolder, "selection.json"));

    % Copy ExactZeros.xlsx
    guiTabularFolder = fullfile(guiFolder, "tabular");
    userTabularFolder = fullfile(".", "tabular");
    gui.createFolder(userTabularFolder);
    copyfile(fullfile(guiTabularFolder, "ExactZeros.xlsx"), fullfile(userTabularFolder, "ExactZeros.xlsx"));

    htmlDir = gui.populateHTML();

    gui.populateMeta();
    gui.populateData();
    gui.populateEstimatorSelection();
    gui.populateIdentificationSelection();

    % Open Matlab web browser
    indexPath = fullfile(htmlDir, 'index.html');
    web(indexPath);

end%
