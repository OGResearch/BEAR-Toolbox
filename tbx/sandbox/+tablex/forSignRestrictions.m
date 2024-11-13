
function tbx = forSignRestrictions(model)
    %
    meta = model.Meta;
    %
    horizon = meta.IdentificationHorizon;
    %
    % Create a table with endogenous variables in rows and shocks in columns,
    % with each entry being a 1-by-horizon vector of NaNs, 1s, or -1s,
    % initialized to all NaNs.
    data = repmat({nan(meta.NumEndogenousNames, horizon)}, 1, meta.NumShockNames);
    tbx = table( ...
        data{:}, ...
        rowNames=meta.EndogenousNames, ...
        variableNames=meta.ShockNames ...
    );
    %
    tbx = tablex.setToVerifiables(tbx, @toVerifiables);
    tbx = tablex.setCheckConsistency(tbx, @checkConsistency);
    %
end%


function expressions = toVerifiables(tbx)
    %[
    tablex.checkConsistency(tbx);
    %
    endogenousNames = string(tbx.Properties.RowNames);
    shockNames = string(tbx.Properties.VariableNames);
    numEndogenousNames = numel(endogenousNames);
    numShockNames = numel(shockNames);
    %
    data = reshape(tbx{:, :}, numEndogenousNames, [], numShockNames);
    ind = find(~isnan(data));
    [row, column, page] = ind2sub(size(data), ind);
    %
    numExpressions = numel(row);
    signs = repmat("", size(row));
    signs(data(ind) == 1) = ">";
    signs(data(ind) == -1) = "<";
    expressions = cell(1, numExpressions);
    for i = 1 : numExpressions
        expressions{i} = sprintf( ...
            "$SHKRESP(%g, '%s', '%s') %s 0", ...
            column(i), ...
            endogenousNames(row(i)), ...
            shockNames(page(i)), ...
            signs(i) ...
        );
    end
    expressions = cat(1, expressions{:});
    %]
end%


function checkConsistency(tbx)
    %[
    numEndogenousNames = numel(tbx.Properties.RowNames);
    numShockNames = numel(tbx.Properties.VariableNames);
    if numEndogenousNames ~= numShockNames
        error("Sign restriction table must have the same number of endogenous names and shock names.")
    end
    %
    data = tbx{:, :}(:);
    if ~(all(isnan(data) | data == 1 | data == -1))
        error("Sign restriction table entries must be either 1, -1, or NaN.");
    end
    %]
end%


