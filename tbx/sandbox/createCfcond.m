
function cfconds = createCfcond(meta, longY, condTable, forecastSpan)

    order = meta.Order;

    shortY = longY(order + 1:end, :);
    endoNames = meta.EndogenousNames;
    numEn = numel(meta.EndogenousNames);

    fcastLength = numel(forecastSpan);
    cfconds = cell(fcastLength, numEn);
    
    for nn = 1 : numEn
        tmp = condTable(:, endoNames(nn));
        nonEmptyRows = ~cellfun(@isempty, tmp.Variables);
        nonEmptyTimes = tmp.Time(nonEmptyRows);
        [~, ix] = ismember(nonEmptyTimes, forecastSpan);
        ix = ix(ix>0);
        if ~isempty(ix)
            cfconds{ix, nn} = shortY(ix, nn);
        end
    end

end