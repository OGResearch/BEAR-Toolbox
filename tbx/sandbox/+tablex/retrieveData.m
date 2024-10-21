
function outArray = retrieveData(varargin)

    [cellArray, periods] = tablex.retrieveDataAsCellArray(varargin{:});
    for i = 1 : numel(cellArray)
        cellArray{i} = permute(cellArray{i}, [1, 3, 2]);
    end
    numPeriods = numel(periods);
    outArray = [zeros(numPeriods, 0), cellArray{:}];

end%

