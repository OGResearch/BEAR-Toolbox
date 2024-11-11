
function dict = createDictionary(list)

    arguments
        list (1, :) string
    end

    dict = struct();

    if isempty(list) || isequal(list, [""])
        return
    end

    for i = 1 : numel(list)
        dict.(list(i)) = i;
    end

end%

