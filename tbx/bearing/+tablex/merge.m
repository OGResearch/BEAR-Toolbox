
function outTable = merge(firstTable, secondTable)

    arguments
        firstTable timetable
        secondTable timetable
    end

    if height(secondTable) == 0
        outTable = firstTable;
        return
    end

    if height(firstTable) == 0
        outTable = secondTable;
        return
    end

    firstNames = string(firstTable.Properties.VariableNames);
    secondNames = string(secondTable.Properties.VariableNames);
    allNames = unique([firstNames, secondNames], "stable");

    [firstSpan, secondSpan, allSpan] = resolveSpans_(firstTable, secondTable);

    numFirstPeriods = numel(firstSpan);
    numSecondPeriods = numel(secondSpan);

    firstData = tablex.retrieveDataAsCellArray(firstTable, firstNames, firstSpan, variant=":");
    secondData = tablex.retrieveDataAsCellArray(secondTable, secondNames, secondSpan, variant=":");

    allData = cell(1, numel(allNames));

    for name = allNames
        nameInFirst = find(name == firstNames, 1);
        nameInSecond = find(name == secondNames, 1);
        nameInAll = find(name == allNames, 1);
        if ~isempty(nameInFirst) && isempty(nameInSecond)
            numVariants = size(firstData{1, nameInFirst}, 2);
            allData{1, nameInAll} = [firstData{1, nameInFirst}; nan(numSecondPeriods, numVariants)];
        elseif isempty(nameInFirst) && ~isempty(nameInSecond)
            numVariants = size(secondData{1, nameInSecond}, 2);
            allData{1, nameInAll} = [nan(numFirstPeriods, numVariants); secondData{1, nameInSecond}];
        else
            numFirstVariants = size(firstData{1, nameInFirst}, 2);
            numSecondVariants = size(secondData{1, nameInSecond}, 2);
            if numFirstVariants == 1 && numSecondVariants > 1
                firstData{1, nameInFirst} = repmat(firstData{1, nameInFirst}, 1, numSecondVariants);
            elseif numFirstVariants > 1 && numSecondVariants == 1
                secondData{1, nameInSecond} = repmat(secondData{1, nameInSecond}, 1, numFirstVariants);
            end
            allData{1, nameInAll} = [firstData{1, nameInFirst}; secondData{1, nameInSecond}];
        end
    end
    outTable = tablex.fromCellArray(allData, allNames, allSpan);

    try
        higherDimNames = tablex.getHigherDims(firstTable);
        outTable = tablex.setHigherDims(outTable, higherDimNames);
    end

end%


function [firstSpan, secondSpan, allSpan] = resolveSpans_(firstTable, secondTable)

    firstSpan = tablex.span(firstTable);
    secondSpan = tablex.span(secondTable);

    fh = datex.Backend.getFrequencyHandlerFromDatetime(firstSpan(1));
    firstStartPeriod = firstSpan(1);
    secondStartPeriod = secondSpan(1);
    firstEndPeriod = datex.shift(secondStartPeriod, -1);
    secondEndPeriod = secondSpan(end);
    firstSpan = datex.span(firstStartPeriod, firstEndPeriod);

    firstNames = string(firstTable.Properties.VariableNames);
    secondNames = string(secondTable.Properties.VariableNames);

    if firstStartPeriod < secondStartPeriod
        allStartPeriod = firstStartPeriod;
    else
        allStartPeriod = secondStartPeriod;
    end
    allEndPeriod = secondEndPeriod;
    allSpan = datex.span(allStartPeriod, allEndPeriod);

end%

