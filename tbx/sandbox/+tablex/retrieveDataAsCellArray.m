
function outArray = retrieveDataAsCellArray(inTable, names, periods, options)

    arguments
        inTable timetable
        names (1, :) string
        periods (1, :) datetime

        options.Variant (1, :) = 1
        options.Shift (1, 1) double = 0
    end

    periods = tablex.resolvePeriods(inTable, periods, shift=options.Shift);

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    numTablePeriods = height(inTable);
    numNames = numel(names);
    numPeriods = numel(periods);

    tableStartPeriod = tablex.startPeriod(inTable);
    fh = datex.Backend.getFrequencyHandlerFromDatetime(tableStartPeriod);
    startSerial = fh.serialFromDatetime(tableStartPeriod);
    requestedSerials = fh.serialFromDatetime(periods);
    positions = requestedSerials - startSerial + 1;
    positions(positions <= 0 | positions > numTablePeriods) = numTablePeriods + 1;

    outArray = cell(1, numNames);
    for i = 1 : numNames
        name = names(i);
        x = inTable.(name)(:, options.Variant);
        x(end+1, :) = NaN;
        outArray{i} = x(positions, :);
    end

end%

