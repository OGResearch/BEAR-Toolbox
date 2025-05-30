
function populateEstimatorSettingsHTML()

    estimatorSettingsPath = fullfile(".", "settings", "estimatorSettings.json");
    estimatorSettings = jsondecode(fileread(estimatorSettingsPath));

    estimatorSelection = gui.querySelection("Estimator");
    form = "";
    if estimatorSelection ~= ""
        settings = estimatorSettings.(estimatorSelection);
        form = gui.createForm(settings, header=estimatorSelection, action="collectEstimatorSettings");
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    inputFile = fullfile(guiFolder, "html", "estimator_settings.html");
    outputFile = fullfile(".", "html", "estimator_settings.html");

    % TODO: $INDEX_CONTENT --> $ESTIMATOR_SETTINGS_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$INDEX_CONTENT", form);

end%
