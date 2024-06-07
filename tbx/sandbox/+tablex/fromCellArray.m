

function tt = fromCellArray(dataCell, names, periods)

    arguments
        dataCell (:, :) cell
        names (1, :) string
        periods (:, 1) datetime
    end

    tt = timetable(dataCell{:}, rowTimes=periods, variableNames=names);

end%

