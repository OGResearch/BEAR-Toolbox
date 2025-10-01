
function targetPath = populateConditionalSettingsHTML()

    FORM_PATH = {"tasks", "conditional"};
    HTML_END_PATH = {"html", "tasks", "conditional.html"};

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    jsonForm = gui.readFormsFile(FORM_PATH);
    htmlForm = gui.generateFreeForm( ...
        jsonForm ...
        , action="gui_collectConditionalSettings" ...
    );

    gui.copyCustomHTML(sourcePath, targetPath, "?FORM?", htmlForm);

end%

