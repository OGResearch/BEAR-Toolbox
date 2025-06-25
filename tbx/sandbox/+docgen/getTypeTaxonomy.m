
function typeTaxonomy = getTypeTaxonomy(type, dim)

    % Check type
    switch type
        case "double"
            typeTaxonomy = "number";
        case "logical"
            typeTaxonomy = "logical";
        case "string"
            typeTaxonomy = "name";
        case "char"
            typeTaxonomy = "name";
        case "function_handle"
            typeTaxonomy = "string";
        case "datetime"
            typeTaxonomy = "string";
        otherwise
            typeTaxonomy = "string";
    end

    % Check dimension
    if ~isempty(dim)
        if length(dim) > 1
            if isnumeric([dim{:}]) && typeTaxonomy == "numeric"
                typeTaxonomy ;
            elseif isnumeric([dim{:}])
                    typeTaxonomy = typeTaxonomy;
            elseif isnumeric(dim{1}) 
                    typeTaxonomy = typeTaxonomy + "s";
            elseif isnumeric(dim{2})
                typeTaxonomy = typeTaxonomy + "s";
            else
                typeTaxonomy = typeTaxonomy + "s";
            end
        else
            typeTaxonomy = typeTaxonomy + "s";
        end
    end

end%

