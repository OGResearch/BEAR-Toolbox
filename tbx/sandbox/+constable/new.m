
function ct = new(rowNames, columnNames, periods, initValue)

    arguments
        rowNames (1, :) string
        columnNames (1, :) string
        periods (1, :) datetime
        initValue (1, 1) = NaN
    end

    numRows = numel(rowNames);
    numColumns = numel(columnNames);
    numPeriods = numel(periods);
    placeholder = repmat(initValue, numRows, numPeriods);
    placeholders = repmat({placeholder}, 1, numColumns);

    ct = table( ...
        placeholders{:} ...
        , rowNames=rowNames ...
        , variableNames=columnNames ...
    )

    ct = addprop(ct, "Periods", "table");
    ct.Properties.CustomProperties.Periods = periods;

end%

