
function targetFile = populateScriptSettingsHTML()

    FORM_PATH = {"script", "settings"};
    CALLBACK_ACTION = "gui_collectScriptSettings";
    HTML_END_PATH = {"html", "script", "settings.html"};
    TARGET_PAGE = {"html", "script", "execution.html"};

    jsonForm = gui.readFormsFile(FORM_PATH);
    htmlForm = gui.generateFreeForm( ...
        jsonForm ...
        , action=CALLBACK_ACTION ...
    );

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, HTML_END_PATH{:});
    targetFile = fullfile(".", HTML_END_PATH{:});

    gui.copyCustomHTML( ...
        sourceFile, targetFile, ...
        "?FORM?", htmlForm ...
    );

end%

