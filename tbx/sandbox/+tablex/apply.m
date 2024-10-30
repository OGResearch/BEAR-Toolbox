

function outTable = apply(inTable, func, varargin)

    arguments
        inTable timetable
        func function_handle
    end
    arguments (Repeating)
        varargin
    end

    names = string(inTable.Properties.VariableNames);
    periods = tablex.span(inTable);
    data = tablex.retrieveDataAsCellArray(inTable, names, periods, variant=":");

    for i = 1 : numel(data)
        data{i} = func(data{i});
    end

    outTable = tablex.fromCellArray(data, names, periods);

    try
        higherDims = tablex.getHigherDims(inTable);
        outTable = tablex.setHigherDims(outTable, higherDims{:});
    end

end%
