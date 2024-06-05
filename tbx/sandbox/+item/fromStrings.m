
function outItems = fromStrings(inputStrings)

    numInputStrings = numel(inputStrings);
    outItems = cell(numInputStrings, 1);
    for i = 1:numInputStrings
        outItems{i} = item.fromString(inputStrings{i});
    end

end%

