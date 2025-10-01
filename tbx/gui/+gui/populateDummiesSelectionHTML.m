
function targetFile = populateDummiesSelectionHTML()

    SELECTION_FORM_PATH = {"dummies", "selection"};
    CALLBACK_ACTION = "gui_collectDummiesSelection";
    HTML_END_PATH = {"html", "dummies", "selection.html"};

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, HTML_END_PATH{:});
    targetFile = fullfile(".", HTML_END_PATH{:});

    function copyCustomHTML_(htmlForm)
        gui.copyCustomHTML( ...
            sourceFile, targetFile ...
            , "?FORM?", htmlForm ...
        );
    end%

    currentModule = gui.getCurrentModule();
    if currentModule == ""
        htmlForm = "<p>You need to choose a reduced-form estimator first</p>";
        copyCustomHTML_(htmlForm);
        return
    end

    estimatorObj = gui.getCurrentEstimatorObj();
    canHaveDummies = isequal(estimatorObj.CanHaveDummies, true);
    if ~canHaveDummies
        htmlForm = "<p>The selected reduced-form estimator does not support dummy variables</p>";
        copyCustomHTML_(htmlForm);
        return
    end

    jsonForm = gui.readFormsFile(SELECTION_FORM_PATH);
    currentSelection = gui.querySelection(form=jsonForm);

    htmlForm = gui.generateFlatButtons( ...
        jsonForm ...
        , currentSelection ...
        , CALLBACK_ACTION...
        , type="checkbox" ...
    );

    copyCustomHTML_(htmlForm);

end%

