
function outArray = retrieveData(varargin)

    cellArray = tablex.retrieveDataAsCellArray(varargin{:});
    for i = 1 : numel(cellArray)
        cellArray{i} = permute(cellArray{i}, [1, 3, 2]);
    end
    outArray = [cellArray{:}];

end%

