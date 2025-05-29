function type_taxonomy = getTypeTaxonomy(type, dim)
    % Check type
    switch type
        case "double"
            type_taxonomy = "number";
        case "logical"
            type_taxonomy = "logical";
        case "string"
            type_taxonomy = "name";
        case "char"
            type_taxonomy = "name";
        case "function_handle"
            type_taxonomy = "string";
        case "datetime"
            type_taxonomy = "string";
        otherwise
            type_taxonomy = "string";
    end

    % Check dimension
    if ~isempty(dim)
        if length(dim) > 1
            if isnumeric([dim{:}]) && type_taxonomy == "numeric"
                type_taxonomy ;
            elseif isnumeric([dim{:}])
                    type_taxonomy = type_taxonomy;          
            elseif isnumeric(dim{1}) 
                    type_taxonomy = type_taxonomy + "s";
            elseif isnumeric(dim{2})
                type_taxonomy = type_taxonomy + "s";
            else
                type_taxonomy = type_taxonomy + "s";
            end
        else
            type_taxonomy = type_taxonomy + "s";
        end
    end
end