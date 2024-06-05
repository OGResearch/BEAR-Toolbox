
function outItems = fromUserInput(inItems)

    numInItems = numel(inItems);
    outItems = cell(numInItems, 1);
    for i = 1:numInItems
        inItem = inItems(i);
        if iscell(item)
            inItem = inItem{1};
        end
        if isstring(inItem) || ischar(inItem)
            outItems{i} = item.fromString(string(inItem));
        else
            outItems{i} = inItem;
        end
    end

end%

