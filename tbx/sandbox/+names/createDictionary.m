
function dict = createDictionary(list)

    arguments
        list (1, :) string
    end

    for i = 1 : numel(list)
        dict.(list(i)) = i;
    end

end%

