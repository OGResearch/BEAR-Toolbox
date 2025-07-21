
function targetPath = populateMetaHTML()

    userSettingsDir = fullfile(".", "settings");
    meta = json.read(fullfile(userSettingsDir,"metaSettings.json"));

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    endPath = {"html", "meta", "settings.html"};
    sourcePath = fullfile(guiFolder, endPath{:});
    targetPath = fullfile(".", endPath{:});

    form = gui.generateFreeForm(meta, action="gui_collectMeta");
    % TODO: $Meta_settings --> $META_SETTINGS_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$META_SETTINGS", form);

end%

