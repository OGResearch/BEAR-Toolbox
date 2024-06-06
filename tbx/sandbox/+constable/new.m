
function ct = new(rowNames, columnNames, periods, fillValue)

    arguments
        rowNames (1, :) string
        columnNames (1, :) string
        periods (1, :)
        fillValue (1, 1)
    end

    numRows = numel(rowNames);
    numColumns = numel(columnNames);
    numPeriods = numel(periods);
    placeholder = repmat(fillValue, numRows, numPeriods);
    placeholders = repmat({placeholder}, 1, numColumns);

    ct = table( ...
        placeholders{:} ...
        , rowNames=rowNames ...
        , variableNames=columnNames ...
    )

    ct = addprop(ct, "Periods", "table");
    ct.Properties.CustomProperties.Periods = periods;

end%

