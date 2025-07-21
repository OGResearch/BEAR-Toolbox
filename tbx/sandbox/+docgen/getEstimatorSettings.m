

function out = getEstimatorSettings()

    settingsDir = docgen.getDirectory("estimator.settings.Tracer");
    files = dir(fullfile(settingsDir, "*.m"));

    out = struct();
    for i = 1 : numel(files)
        fileName = string(files(i).name);
        estimatorClassName = extractBefore(files(i).name, ".m");
        try
            estimatorObject = estimator.(estimatorClassName);
            estimatorSettingsObject = estimator.settings.(estimatorClassName);
            estimatorMC = metaclass(estimatorObject);
            setttingsMC = metaclass(estimatorSettingsObject);
        catch Exc
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
                DefaultValue = "";
            end

            % Deal with the function handler as a dirty fix for now
            if isa(DefaultValue, "function_handle")
                DefaultValue = "function handle";
            end

            % collect type
            if isempty(prop.Validation)
                Type = class(DefaultValue);
            else
                Type = prop.Validation.Class.Name;
            end

            % collect Size
            if isempty(prop.Validation)
                sz = "";
            else
                sz = prop.Validation.Size;
            end
            len = length(sz);
            dim = cell(1:len);
            for k = 1:len
                if isa(sz(k),"meta.FixedDimension") 
                    dim{k} = sz(k).Length;
                else
                    dim{k} = ":";
                end
            end
            if isempty(dim)
                dim = "";
            end
            try
                typeTaxonomy = docgen.getTypeTaxonomy(Type, dim);
            catch
                keyboard
            end
            dim = "[" + join(textual.stringify(dim),",") + "]";

            % settings.(prop.Name) = {prop.Description, DefaultValue, Type, dim, typeTaxonomy, prop.DetailedDescription};
            settings.(prop.Name).description = prop.Description;
            settings.(prop.Name).type = typeTaxonomy;
            settings.(prop.Name).value = DefaultValue;
            settings.(prop.Name).details = prop.DetailedDescription;
        end

        try 
            estimatorReference = estimator.(estimatorClassName).getModelReference();
        catch
            estimatorReference = [];
        end

        % if ~isempty(estimatorReference) && isfield(estimatorReference, "category")
        %     out.(estimatorReference.category).(estimatorClassName).settings = settings;
        %     out.(estimatorReference.category).(estimatorClassName).description = estimatorMC.Description;
        %     out.(estimatorReference.category).(estimatorClassName).detailedDesc = estimatorMC.DetailedDescription;
        % end
        out.(estimatorClassName) = settings;

    end

end%


