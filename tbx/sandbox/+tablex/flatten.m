%
% flatten  Flatten higher dimensions of time series in a table into separate
% table variables
%

function flatTable = flatten(table, options)

    arguments
        table timetable
        %
        options.Separator (1, 1) string = "___"
    end

    higherDims = tablex.getHigherDims(table);

    if isempty(higherDims)
        flatTable = table;
        return
    end

    span = tablex.span(table);
    names = table.Properties.VariableNames;
    numNames = numel(names);
    flatNames = textual.crossList(options.Separator, names, higherDims{:});

    numFlatNames = numel(flatNames);
    flatData = cell(1, numFlatNames);
    index = 1;
    for n = reshape(string(names), 1, [])
        numCols = size(table.(n), 2);
        for i = 1 : numCols : size(flatData, 2)
            flatData{index} = table.(n)(:, i+(0:numCols-1));
            index = index + 1;
        end
    end

    flatTable = tablex.fromCellArray(flatData, flatNames, span);

end%

