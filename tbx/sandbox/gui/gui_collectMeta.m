
function gui_collectMeta(submission)

    arguments
        submission (1, 1) string
    end

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    userSettingsDir = fullfile(".", "settings");

    % read current metadata
    jsonFilePath = fullfile(userSettingsDir, "metaSettings.json");
    meta = json.read(jsonFilePath);

    % data cleanup
    userData = gui.resolveCleanFormSubmission(submission, meta);

    % update metadata with userData
    meta = gui.updateData(meta, userData);

    % save updated metadata to file
    json.write(meta, jsonFilePath, prettyPrint=true);

    gui.updateExactZerosXLSX();

    metaPath = gui.populateMetaHTML();
    web(metaPath);

end%

