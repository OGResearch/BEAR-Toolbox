
function targetPath = populateEstimatorSettingsHTML()

    NO_SELECTION_TEXT = "<p>Select an estimator first to edit its settings</p>";
    HTML_END_PATH = {"html", "estimation", "settings.html"};

    estimator = gui.getCurrentEstimator();

    if estimator ~= ""
        estimatorSettings = gui.getCurrentEstimatorSettings();
        htmlForm = gui.generateFreeForm( ...
            estimatorSettings ...
            , header=estimator ...
            , action="gui_collectEstimatorSettings" ...
            , getFields = @(x) sort(textual.fields(x)) ...
        );
    else
        htmlForm = NO_SELECTION_TEXT;
    end

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});
    gui.copyCustomHTML(sourcePath, targetPath, "?FORM?", htmlForm);

end%

