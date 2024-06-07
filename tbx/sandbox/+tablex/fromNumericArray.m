

function tt = fromNumericArray(dataArray, names, periods)

    arguments
        dataArray (:, :, :) double
        names (1, :) string
        periods (:, 1) datetime
    end

    numData = size(dataArray, 2);
    dataCell = cell(1, numData);
    for i = 1 : numData
        dataCell{i} = permute(dataArray(:, i, :), [1, 3, 2]);
    end
    tt = timetable(dataCell{:}, rowTimes=periods, variableNames=names);

end%

