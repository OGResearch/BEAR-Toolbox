
function populateMetaHTML()

    userSettingsDir = fullfile(".", "settings");
    meta = json.read(fullfile(userSettingsDir,"metaSettings.json"));

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    inputFile = fullfile(guiFolder, "html", "meta.html");
    outputFile = fullfile(".", "html", "meta.html");

    form = gui.createForm(meta, action="collectMeta");
    % TODO: $Meta_settings --> $META_SETTINGS_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$Meta_settings", form);

end%

