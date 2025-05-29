function out = settings2json()
    % clear cache of all classes
    clear classes

    currentFile = which('docgen.settings2json');
    sandboxDir = fileparts(fileparts(currentFile));

    guiDir = fullfile(sandboxDir, 'gui','settings');

    estimatorSettings = docgen.getEstimatorSettings();
    % repack the settings into a simple struct
    estimatorSettingsPackage = struct();
    categories = fieldnames(estimatorSettings);
    for category_ind = 1:numel(categories)
        category = categories{category_ind};
        estimators = fieldnames(estimatorSettings.(category));
        for estimator_ind = 1:numel(estimators)
            estimatorName = estimators{estimator_ind};
            estimatorSettingsPackage.(estimatorName) = estimatorSettings.(category).(estimatorName).settings;
        end
    end

    saveStruct2Json(estimatorSettingsPackage, ...
        fullfile(sandboxDir, 'estimatorSettings.json'));
    saveStruct2Json(estimatorSettingsPackage, ...
        fullfile(guiDir, 'estimatorSettings.json'));

    metaSettings = docgen.getMetaSettings();
    saveStruct2Json(metaSettings, ...
        fullfile(sandboxDir, 'metaSettings.json'));
    saveStruct2Json(metaSettings, ...
        fullfile(guiDir, 'metaSettings.json'));

end

function saveStruct2Json(settings, jsonFilePath)
    jsonStr = jsonencode(settings, ...
        'PrettyPrint', true);
    % save the JSON string to a file
    fid = fopen(jsonFilePath, 'w');
    if fid == -1
        error('Could not open file %s for writing.', jsonFilePath);
    end
    fprintf(fid, '%s', jsonStr);
    fclose(fid);
end