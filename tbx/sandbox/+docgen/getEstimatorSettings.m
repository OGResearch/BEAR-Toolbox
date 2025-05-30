

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
            % collect default value
            if prop.HasDefault
                DefaultValue = prop.DefaultValue;
            else 
                DefaultValue = '';
            end
            % Deal with the function handler as a dirty fix for now
            if isa(DefaultValue, 'function_handle')
                DefaultValue = 'function handle';
            end

            % collect type
            if isempty(prop.Validation)
                Type = class(DefaultValue);
            else
                Type = prop.Validation.Class.Name;
            end

            % collect Size
            if isempty(prop.Validation)
                sz = '';
            else
                sz = prop.Validation.Size;
            end
            len = length(sz);
            dim = cell(1:len);
            for k = 1:len
                if isa(sz(k),'meta.FixedDimension') 
                    dim{k} = sz(k).Length;
                else
                    dim{k} = ':';
                end
            end
            if isempty(dim)
                dim = '';
            end
            try
                type_taxonomy = docgen.getTypeTaxonomy(Type, dim);
            catch
                keyboard
            end
            dim = "[" + join(textual.stringify(dim),",") + "]";

            % settings.(prop.Name) = {prop.Description, DefaultValue, Type, dim, type_taxonomy, prop.DetailedDescription};
            settings.(prop.Name).description = prop.Description;
            settings.(prop.Name).type = type_taxonomy;
            settings.(prop.Name).default = DefaultValue;
            settings.(prop.Name).detailedDesc = prop.DetailedDescription;
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


