
function tbx = forSignRestrictions(model)

    meta = model.Meta;
    data = repmat({repmat("", meta.NumEndogenousNames, 1)}, 1, meta.NumShockNames);
    tbx = table( ...
        data{:}, ...
        rowNames=meta.EndogenousNames, ...
        variableNames=meta.ShockNames ...
    );

end%


