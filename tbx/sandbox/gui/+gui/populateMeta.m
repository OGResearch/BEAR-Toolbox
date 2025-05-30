
function populateMeta()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    userSettingsDir = "settings";
    if ~exist(userSettingsDir, "dir")
        mkdir(userSettingsDir);
    end

    copyfile(fullfile(guiFolder, "settings", "metaSettings.json"), fullfile(userSettingsDir, "metaSettings.json"));
    meta = json.read(fullfile(userSettingsDir,"metaSettings.json"));

    inputFile = fullfile(guiFolder, "html", "meta.html");
    outputFile = fullfile("html", "meta.html");
    gui.updateMetaPage(inputFile, outputFile, meta);

end%

