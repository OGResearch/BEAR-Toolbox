
function tbl = replaceMissing(tbl)
% Replace missing values with NaN (for numeric columns) or "" (for string
% columns).

    TIME_COLUMN = "Time";
    columnNames = tablex.getColumnNames(tbl);
    columnNames = setdiff(columnNames, TIME_COLUMN, "stable");

    for n = columnNames
        data = tbl{:, n};
        if isstring(data)
            data(ismissing(data)) = "";
        elseif isnumeric(data)
            data(ismissing(data)) = NaN;
        end
        tbl{:, n} = data;
    end

end%

