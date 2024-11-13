
function tbx = forExactZeros(model)
    %
    meta = model.Meta;
    %
    % Create a table with endogenous variables in rows and shocks in columns,
    % initialized to all NaNs.
    data = repmat({nan(meta.NumEndogenousNames, 1)}, 1, meta.NumShockNames);
    tbx = table( ...
        data{:}, ...
        rowNames=meta.EndogenousNames, ...
        variableNames=meta.ShockNames ...
    );
    %
    tbx = tablex.setCheckConsistency(tbx, @checkConsistency);
    %
end%


function checkConsistency(tbx)
    %[
    %
    % Each entry must be either 0 or NaN
    R = tbx{:, :};
    if ~all(isnan(R(:)) | R(:) == 0)
        error("Exact zero restriction table entries must be either 0 or NaN.");
    end
    %
    % The number of exact zero restrictions is limited by the number of
    % variables
    numVariables = size(R, 1);
    numRestrictions = nnz(R == 0);
    maxNumRestrictions = numVariables * (numVariables - 1) / 2 - 1;
    if numRestrictions > maxNumRestrictions
        error( ...
            "Too many exact zero restrictions for the number of variables; max %g allowed." ...
            , maxNumRestrictions ...
        );
    end
    %]
end%

