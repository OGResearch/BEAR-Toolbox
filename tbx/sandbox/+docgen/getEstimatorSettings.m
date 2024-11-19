

function out = getEstimatorSettings()

    settingsDir = docgen.getDirectory("estimator.settings.Tracer");
    files = dir(fullfile(settingsDir, "*.m"));
    out = struct();
    for i = 1 : numel(files)
        name = extractBefore(files(i).name, ".m");
        try
            estimatorMC = metaclass(estimator.(name));
            setttingsMC = metaclass(estimator.settings.(name));
        catch
            continue
        end
        settings = struct();
        for i = 1 : numel(setttingsMC.PropertyList)
            prop = setttingsMC.PropertyList(i);
            if prop.Hidden || prop.Constant
                continue
            end
            settings.(prop.Name) = {prop.DefaultValue, prop.Description};
        end
        out.(name) = settings;
    end

end%

