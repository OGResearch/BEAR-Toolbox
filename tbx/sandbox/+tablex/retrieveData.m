
function outArray = retrieveData(inTable, names, periods, options)

    arguments
        inTable timetable
        names (1, :) string
        periods (1, :) datetime
        options.Variant (1, 1) double = 1
        options.Shift (1, 1) double = 0
    end

    tablePeriods = inTable.Properties.RowTimes;
    periods = tablex.resolvePeriods(inTable, periods, shift=options.Shift);

    numTablePeriods = numel(tablePeriods);
    numColumns = numel(names);
    numPeriods = numel(periods);
    outArray = nan(numPeriods, numColumns);

    fh = datex.Backend.getFrequencyHandlerFromDatetime(tablePeriods(1));
    startSerial = fh.serialFromDatetime(tablePeriods(1));
    requestedSerials = fh.serialFromDatetime(periods);
    positions = requestedSerials - startSerial + 1;
    positions(positions <= 0 | positions > numTablePeriods) = numTablePeriods + 1;

    for n = names
        x = inTable.(n)(:, options.Variant);
        x(end+1, :) = NaN;
        outArray(:, n == names) = x(positions);
    end

end%

