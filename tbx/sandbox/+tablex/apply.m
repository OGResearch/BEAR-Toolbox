

function outTable = apply(inTable, func, varargin)

    names = string(inTable.Properties.VariableNames);
    periods = tablex.span(inTable);
    data = tablex.retrieveDataAsCellArray(inTable, names, periods, variant=":");

    for i = 1:numel(data)
        data{i} = func(data{i});
    end

    outTable = tablex.fromCellArray(data, names, periods);

end%
