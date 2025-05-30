
function populateEstimatorSelectionHTML()

    userSettingsFolder = fullfile(".", "settings");
    estimatorSettings = json.read(fullfile(userSettingsFolder, "estimatorSettings.json"));

    shortList = ["Minnesota", "NormalDiffuse", "NormalWishart", "GenLargeShockSV"];
    shortSettings = struct();
    for n = shortList
        shortSettings.(n) = [];
    end
    currentSelection = gui.querySelection("Estimator");
    form = gui.generateRadioButtonsForm(shortSettings, "Estimator", currentSelection, "collectEstimatorSelection");

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    inputFile = fullfile(guiFolder, "html", "estimator_selection.html");
    outputFile = fullfile(".", "html", "estimator_selection.html");
    % TODO: $ESTIMATOR_LIST --> $ESTIMATOR_SELECTION_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$ESTIMATOR_LIST", form);

end%

