
function populateDataHTML()

    userSettingsFolder = fullfile(".", "settings");
    data = json.read(fullfile(userSettingsFolder, "dataSettings.json"));

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    inputFile = fullfile(guiFolder, "html", "data.html");
    outputFile = fullfile(".", "html", "data.html");

    form = gui.createForm(data, action="collectData");
    % TODO: $Data_settings --> $DATA_SETTINGS_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$data_file_name", form);

end%
