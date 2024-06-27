
function allYLX = mergeYLX(firstYLX, varargin)

    allYLX = firstYLX;
    for i = 1 : numel(varargin)
        for j = 1 : numel(firstYLX)
            allYLX{j} = [allYLX{j}; varargin{i}{j}];
        end
    end

end%
