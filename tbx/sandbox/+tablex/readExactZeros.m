
function tbl = readSignRestrictions(fileName, vararging)

    arguments
        fileName (1, 1) string
    end

    arguments (Repeating)
        varargin
    end

    tbl = tablex.readtable( ...
        fileName, ...
        , convertTo=@string  ...
        , varargin{:} ...
    );

    % Validate data in the table
    tablex.validateExactZeros(tbl);

end%

