
function targetPath = populateEstimatorSettingsHTML()

    NO_SELECTION_TEXT = join([
        "<p>"
        "Select an estimator first to edit its settings."
        "</p>"
    ], newline());

    estimatorSelection = gui.querySelection("Estimator");

    if estimatorSelection ~= ""
        estimatorSettings = gui.querySelection("EstimatorSettings");
        form = gui.generateFreeForm(estimatorSettings, header=estimatorSelection, action="gui_collectEstimatorSettings");
    else
        form = NO_SELECTION_TEXT;
        estimatorSettings = struct();
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    endPath = {"html", "estimation", "settings.html"};
    sourcePath = fullfile(guiFolder, endPath{:});
    targetPath = fullfile(".", endPath{:});
    gui.changeHtmlFile(sourcePath, targetPath, "$ESTIMATOR_SETTINGS_FORM", form);

end%

