
function write(json, fileName, options)

    arguments
        json
        fileName (1, 1) string
        options.PrettyPrint logical = false
    end

    if ~isstring(json)
        json = jsonencode(json, "PrettyPrint", options.PrettyPrint);
    end

    writematrix( ...
        json, fileName ...
        , fileType="text" ...
        , quoteStrings=false ...
    );

end%

