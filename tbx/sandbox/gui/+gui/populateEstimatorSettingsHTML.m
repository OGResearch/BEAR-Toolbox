
function targetPath = populateEstimatorSettingsHTML()

    estimatorSettingsPath = fullfile(".", "settings", "estimatorSettings.json");
    estimatorSettings = jsondecode(fileread(estimatorSettingsPath));

    estimatorSelection = gui.querySelection("Estimator");
    form = "";
    if estimatorSelection ~= ""
        settings = estimatorSettings.(estimatorSelection);
        form = gui.createForm(settings, header=estimatorSelection, action="gui_collectEstimatorSettings");
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    sourcePath = fullfile(guiFolder, "html", "estimator_settings.html");
    targetPath = fullfile(".", "html", "estimator_settings.html");

    gui.changeHtmlFile(sourcePath, targetPath, "$ESTIMATOR_SETTINGS_FORM", form);

end%
