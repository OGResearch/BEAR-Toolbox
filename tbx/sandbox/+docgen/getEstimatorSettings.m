

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
            % comment out for now, will see if we need it later
            % DefaultValue = '';
            % if isfield(prop,'DefaultValue')
            %     DefaultValue = prop.DefaultValue;
            % end
            settings.(prop.Name) = {prop.Description, prop.DetailedDescription};
        end
        try 
            estimatorReference = estimator.(name).getModelReference();
        catch
            estimatorReference = [];
        end
        if ~isempty(estimatorReference) && isfield(estimatorReference, "category")
            out.(estimatorReference.category).(name).settings = settings;
            out.(estimatorReference.category).(name).description = estimatorMC.Description;
            out.(estimatorReference.category).(name).detailedDesc = estimatorMC.DetailedDescription;
        end

    end

end%

