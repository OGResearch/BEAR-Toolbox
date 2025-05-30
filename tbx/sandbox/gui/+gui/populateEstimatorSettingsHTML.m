
function targetPath = populateEstimatorSettingsHTML()

    estimatorSettingsPath = fullfile(".", "settings", "estimatorSettings.json");
    estimatorSettings = jsondecode(fileread(estimatorSettingsPath));

    estimatorSelection = gui.querySelection("Estimator");
    form = "";
    if estimatorSelection ~= ""
        settings = estimatorSettings.(estimatorSelection);
        form = gui.createForm(settings, header=estimatorSelection, action="collectEstimatorSettings");
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    sourcePath = fullfile(guiFolder, "html", "estimator_settings.html");
    targetPath = fullfile(".", "html", "estimator_settings.html");

    % TODO: $INDEX_CONTENT --> $ESTIMATOR_SETTINGS_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$INDEX_CONTENT", form);

end%
