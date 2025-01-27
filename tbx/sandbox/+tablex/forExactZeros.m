%{
%
% tablex.forExactZeros  Create a new empty restriction table for exact zeros identifier
%
%     r = rablex.ForExactZeros(modelR)
%
%}

function tbx = forExactZeros(model)
    %
    meta = model.Meta;
    separableEndogenousNames = meta.SeparableEndogenousNames;
    separableShockNames = meta.SeparableShockNames;
    %
    % Create a table with endogenous variables in rows and shocks in columns,
    % initialized to all NaNs.
    numEndogenousLabels = numel(separableEndogenousNames);
    numShockLabels = numel(separableShockNames);
    data = repmat({nan(numEndogenousLabels, 1)}, 1, numShockLabels);
    tbx = table( ...
        data{:}, ...
        rowNames=separableEndogenousNames, ...
        variableNames=separableShockNames ...
    );
    %
    tbx = tablex.setCheckConsistency(tbx, @checkConsistency_);
    %
end%


function checkConsistency_(tbx)
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

