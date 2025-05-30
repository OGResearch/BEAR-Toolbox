
function populateEstimatorSelection()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    userSettingsFolder = "settings";
    if ~exist(userSettingsFolder, "dir")
        mkdir(userSettingsFolder);
    end
    copyfile(fullfile(guiFolder, "settings", "estimatorSettings.json"), fullfile(userSettingsFolder, "estimatorSettings.json"));
    estimatorSettings = json.read(fullfile(userSettingsFolder, "estimatorSettings.json"));

    shortList = ["Minnesota", "NormalDiffuse", "NormalWishart", "GenLargeShockSV"];
    shortSettings = struct();
    for n = shortList
        shortSettings.(n) = [];
    end
    currentSelection = gui.querySelection("Estimator");
    form = gui.generateRadioButtonsForm(shortSettings, "Estimator", currentSelection, "collectEstimatorSelection");

    inputFile = fullfile(guiFolder, "html", "estimator_select.html");
    outputFile = fullfile("html", "estimator_select.html");
    % TODO: $ESTIMATOR_LIST --> $ESTIMATOR_SELECTION_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$ESTIMATOR_LIST", form);

end%

