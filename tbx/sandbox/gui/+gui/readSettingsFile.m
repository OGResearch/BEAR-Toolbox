
function content = readSettingsFile(fileTitle)

    arguments
        fileTitle (1, 1) string
    end

    localSettingsFolder = fullfile(".", "settings");
    settingsFilePath = fullfile(localSettingsFolder, fileTitle + ".json");
    content = json.read(settingsFilePath);

end%

