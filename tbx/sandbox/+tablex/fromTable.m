
function tt = fromTable(plainTable, options)

    arguments
        plainTable table
        options.TimeRow (1, 1) string = "Time"
    end

    if height(plainTable) == 0
        error("Cannot handle empty tables");
    end

    timeColumn = plainTable.(options.TimeRow);
    if isstring(timeColumn) || iscellstr(timeColumn)
        timeColumn = datex.fromSdmx(timeColumn);
    end

    plainTable = removevars(plainTable, options.TimeRow);
    tt = table2timetable(plainTable, rowTimes=timeColumn);

end%

