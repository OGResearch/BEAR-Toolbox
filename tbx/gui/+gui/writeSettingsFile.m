
function writeSettingsFile(content, fileTitle, varargin)

    arguments
        content
        fileTitle (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    localSettingsFolder = fullfile(".", "settings");
    settingsFilePath = fullfile(localSettingsFolder, fileTitle + ".json");
    json.write(content, settingsFilePath, varargin{:});

end%

