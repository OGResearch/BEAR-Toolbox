
function tbl = convert(tbl, convertTo)

    if isempty(convertTo) || isequal(convertTo, "")
        return
    end

    TIME_COLUMN = "Time";
    columnNames = tablex.getColumnNames(tbl);
    columnNames = setdiff(columnNames, TIME_COLUMN, "stable");

    tbl = convertvars(tbl, columnNames, convertTo);

end%

