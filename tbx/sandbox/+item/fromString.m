
function outItem = fromString(inputString)

    inputString = strip(inputString);
    if item.isSpecial(inputString)
        outItem = item.createSpecial(extractAfter(inputString, 1));
    else
        outItem = item.Variable(inputString);
    end

end%
