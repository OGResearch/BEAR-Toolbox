
function tbx = forSignRestrictions(model)

    meta = model.getMeta();
    separableEndogenousNames = meta.getSeparableEndogenousNames();
    separableShockNames = meta.getSeparableShockNames();

    data = repmat({repmat("", meta.NumEndogenousNames, 1)}, 1, meta.NumShockNames);

    tbx = table( ...
        data{:}, ...
        rowNames=separableEndogenousNames, ...
        variableNames=separableShockNames ...
    );

end%


