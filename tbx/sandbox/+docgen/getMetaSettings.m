function out = getMetaSettings()
% getMetaSettings - Get the metadata settings for the documentation generator

    ModelDir = docgen.getDirectory("model.Tracer");
    files = dir(fullfile(ModelDir, "Meta.m"));
    out = struct();
    for i = 1 : numel(files)
        name = extractBefore(files(i).name, ".m");
        try
            modelMC = eval(['?' 'model.' name]);
        catch
            continue
        end
    end

    % collect the properties of the model class
    properties = modelMC.PropertyList;

    for i = 1 : numel(properties)
        prop = properties(i);
        if prop.Hidden || prop.Constant || prop.Dependent
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
        if isempty(prop.Validation) && ~prop.HasDefault
            Type = "unknown";
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
        
        type_taxonomy = docgen.getTypeTaxonomy(Type, dim);

        out.(name).(prop.Name) = struct(...
            'default', DefaultValue, ...
            'type', type_taxonomy, ...
            'Description', prop.Description ...
        );
    end

end
