
function periods = span(inTable)
    startPeriod = tablex.startPeriod(inTable);
    endPeriod = tablex.endPeriod(inTable);
    periods = datex.span(startPeriod, endPeriod);
end%

