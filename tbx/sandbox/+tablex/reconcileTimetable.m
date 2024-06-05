
function outTable = reconcileTimetable(inTable, freq)

    if height(inTable) == 0
        return
    end

    fh = datex.Backend.getFrequencyHandlerFromFrequency(freq);

    dates = inTable.Time;
    dates = fh.datetimeFromDatetime(dates);

    uniqueDates = unique(dates);
    if numel(uniqueDates) ~= numel(dates)
        error("Duplicate dates found in timetable")
    end

    periods = fh.datetimeFromDatetime(dates);
    serials = fh.serialFromDatetime(periods);
    minSerial = min(serials);
    maxSerial = max(serials);
    numPeriods = maxSerial - minSerial + 1;
    newSerials = reshape(minSerial : maxSerial, [], 1);
    newPeriods = fh.datetimeFromSerial(newSerials);
    positions = serials - minSerial + 1;

    variableNames = string(inTable.Properties.VariableNames);
    numVariables = numel(variableNames);
    storeData = cell.empty(1, 0);
    for name = string(inTable.Properties.VariableNames)
        variable = inTable.(name);
        numColumns = size(variable, 2);
        array = nan(numPeriods, numColumns);
        array(positions, :) = variable;
        storeData{end+1} = array;
    end

    outTable = timetable(newPeriods, storeData{:}, variableNames=variableNames);

end%

