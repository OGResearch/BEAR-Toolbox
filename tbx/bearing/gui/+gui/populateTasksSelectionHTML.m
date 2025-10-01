
function populateRunSelectionHTML()

    FORM_PATH = {"tasks", "selection"};
    CALLBACK_ACTION = "gui_collectTasksSelection";
    HTML_END_PATH = {"html", "tasks", "selection.html"};

    jsonForm = gui.readFormsFile(FORM_PATH);
    currentSelection = gui.querySelection(form=jsonForm);

    htmlForm = gui.generateFlatButtons( ...
        jsonForm ...
        , currentSelection ...
        , CALLBACK_ACTION...
        , type="checkbox" ...
    );

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, HTML_END_PATH{:});
    targetFile = fullfile(".", HTML_END_PATH{:});

    gui.copyCustomHTML( ...
        sourceFile, targetFile, ...
        "?FORM?", htmlForm ...
    );

end%

