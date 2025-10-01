
function targetFile = populateEstimatorSelectionHTML()

    FORM_PATH = {"estimation", "selection"};
    CALLBACK_ACTION = "gui_collectEstimatorSelection";
    HTML_END_PATH = {"html", "estimation", "selection.html"};
    NO_SELECTION = "[No estimator selected]";

    jsonForm = gui.readFormsFile(FORM_PATH);
    currentEstimator = gui.getCurrentEstimator();

    categories = gui.readFormsFile({"estimation", "categories"});
    htmlForm = gui.generateCategorizedButtons( ...
        jsonForm ...
        , currentEstimator ...
        , categories ...
        , CALLBACK_ACTION...
    );

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, HTML_END_PATH{:});
    targetFile = fullfile(".", HTML_END_PATH{:});

    if currentEstimator ~= ""
        currentSelection = currentEstimator;
    else
        currentSelection = NO_SELECTION;
    end

    gui.copyCustomHTML( ...
        sourceFile, targetFile, ...
        "?FORM?", htmlForm, ...
        "?CURRENT_SELECTION?", currentSelection ...
    );

end%

