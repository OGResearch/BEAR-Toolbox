
function targetFile = populateIdentificationSelectionHTML()

    SELECTION_FORM_PATH = {"identification", "selection"};
    CALLBACK_ACTION = "gui_collectIdentificationSelection";
    HTML_END_PATH = {"html", "identification", "selection.html"};

    NO_ESTIMATOR_FORM = "<p>You need to choose a reduced-form estimator first</p>";
    CANNOT_IDENTIFY_FORM = "<p>The selected reduced-form estimator does not support structural identification</p>";
    NO_SELECTION_TEXT = "[No identification scheme selected]";

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    function copyCustomHTML_(htmlForm, currentSelection)
        gui.copyCustomHTML( ...
            sourcePath, targetPath, ...
            "?FORM?", htmlForm, ...
            "?CURRENT_SELECTION?", currentSelection ...
        );
    end%

    if gui.getCurrentModule() == ""
        copyCustomHTML_(NO_ESTIMATOR_FORM, NO_SELECTION_TEXT);
        return
    end

    if ~gui.canBeIdentified()
        copyCustomHTML_(CANNOT_IDENTIFY_FORM, NO_SELECTION_TEXT);
        return
    end

    jsonForm = gui.readFormsFile(SELECTION_FORM_PATH);
    currentSelection = gui.querySelection(form=jsonForm, count=[0, 1]);

    htmlForm = gui.generateFlatButtons( ...
        jsonForm ...
        , currentSelection ...
        , CALLBACK_ACTION...
    );
    copyCustomHTML_(htmlForm, currentSelection);

end%

