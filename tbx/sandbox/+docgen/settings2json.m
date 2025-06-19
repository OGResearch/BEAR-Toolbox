function out = settings2json()
    % clear cache of all classes
    clear classes
    rehash path

    currentFile = which('docgen.settings2json');
    sandboxDir = fileparts(fileparts(currentFile));

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

    docgen.saveStruct2Json(estimatorSettingsPackage, ...
        fullfile(sandboxDir, 'estimatorSettings.json'));

    modelSettings = docgen.getMetaSettings();
    docgen.saveStruct2Json(modelSettings, ...
        fullfile(sandboxDir, 'modelSettings.json'));

end
