function type_taxonomy = getTypeTaxonomy(type, dim)
    % Check type
    switch type
        case "double"
            type_taxonomy = "numeric";
        case "logical"
            type_taxonomy = "logical";
        case "string"
            type_taxonomy = "text";
        case "char"
            type_taxonomy = "text";
        case "function_handle"
            type_taxonomy = "function handle";
        otherwise
            type_taxonomy = "undefined";
    end

    % Check dimension
    if ~isempty(dim)
        if length(dim) > 1
            if isnumeric([dim{:}]) && type_taxonomy == "numeric"
                type_taxonomy = type_taxonomy + " scalar";
            elseif isnumeric([dim{:}])
                    type_taxonomy = type_taxonomy;          
            elseif isnumeric(dim{1}) 
                    type_taxonomy = type_taxonomy + " list";
            elseif isnumeric(dim{2})
                type_taxonomy = type_taxonomy + " vector";
            else
                type_taxonomy = type_taxonomy + " matrix";
            end
        else
            type_taxonomy = type_taxonomy + " matrix";
        end
    end
end