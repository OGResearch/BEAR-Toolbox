
function write(json, fileName)

    if ~isstring(json)
        json = jsonencode(json);
    end

    writematrix( ...
        json, fileName ...
        , fileType="text" ...
        , quoteStrings=false ...
    );

end%

