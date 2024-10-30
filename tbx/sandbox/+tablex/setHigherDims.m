
function table = setHigherDims(table, varargin)

    try
        table = addprop(table, "HigherDims", "table");
    end
    table.Properties.CustomProperties.HigherDims = varargin;

end%

