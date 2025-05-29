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

    json.write(estimatorSettingsPackage, ...
        fullfile(sandboxDir, 'estimatorSettings.json'));
        json.write(estimatorSettingsPackage, ...
        fullfile(guiDir, 'estimatorSettings.json'));

    metaSettings = docgen.getMetaSettings();
    json.write(metaSettings, ...
        fullfile(sandboxDir, 'metaSettings.json'));
        json.write(metaSettings, ...
        fullfile(guiDir, 'metaSettings.json'));

    dataSettings = struct();
    dataSettings.FileName.value = '';
    dataSettings.FileName.type = 'string';
    json.write(dataSettings, ...
        fullfile(sandboxDir, 'dataSettings.json'));
    json.write(dataSettings, ...
        fullfile(guiDir, 'dataSettings.json'));

end