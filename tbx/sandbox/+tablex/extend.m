%{
%
% tablex.clip  Clip a timetable to a new span
%
%}

function tt = extend(tt, newStartPeriod, newEndPeriod)

    startPeriod = tt.Time(1);
    endPeriod = tt.Time(end);

    numPrepend = datex.diff(startPeriod, newStartPeriod);
    numAppend = max(0, datex.diff(newEndPeriod, endPeriod));

    names = tablex.names(tt);
    span = tablex.span(tt);

    data = tablex.retrieveDataAsCellArray(tt, names, span, variant=':');

end%

