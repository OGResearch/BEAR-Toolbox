
function targetPath = populateMetaSettingsHTML()

    NO_ESTIMATOR_TEXT = "<p>You need to choose a reduced-form estimator first</p>";
    HTML_END_PATH = {"html", "meta", "settings.html"};

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    htmlForm = NO_ESTIMATOR_TEXT;
    metaSettings = gui.getCurrentMetaSettings();
    if ~isempty(metaSettings)
        htmlForm = gui.generateFreeForm( ...
            metaSettings ...
            , action="gui_collectMetaSettings" ...
        );
    end

    gui.copyCustomHTML( ...
        sourcePath, targetPath ...
        , "?FORM?", htmlForm ...
    );

end%

