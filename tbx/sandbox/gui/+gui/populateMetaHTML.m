
function targetPath = populateMetaHTML()

    userSettingsDir = fullfile(".", "settings");
    meta = json.read(fullfile(userSettingsDir,"metaSettings.json"));

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    sourcePath = fullfile(guiFolder, "html", "meta.html");
    targetPath = fullfile(".", "html", "meta.html");

    form = gui.createForm(meta, action="gui_collectMeta");
    % TODO: $Meta_settings --> $META_SETTINGS_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$Meta_settings", form);

end%

