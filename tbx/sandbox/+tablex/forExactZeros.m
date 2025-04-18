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
    % tbx = tablex.setCheckConsistency(tbx, @checkConsistency_);
    %
end%


function checkConsistency_(tbx)
    %[
    %
    % Each entry must be either 0 or NaN
    %]
end%

