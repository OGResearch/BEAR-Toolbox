
function targetPath = populateInputDataHTML()

    % userSettingsFolder = fullfile(".", "settings");
    % data = json.read(fullfile(userSettingsFolder, "dataSettings.json"));

    inputDataFileSelection = gui.querySelection("InputDataFile");
    if inputDataFileSelection == ""
        inputDataFileSelection = "[No input data file selected]";
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    sourcePath = fullfile(guiFolder, "html", "input_data.html");
    targetPath = fullfile(".", "html", "input_data.html");

    % form = gui.createForm(data, action="gui_collectData");
    % TODO: $Data_settings --> $DATA_SETTINGS_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$INPUT_DATA_FILE", inputDataFileSelection);

end%

