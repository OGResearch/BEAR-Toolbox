
function [tt, freq] = fromFile(fileType, fileName, options)

    arguments
        fileType (1, 1) string
        fileName (1, 1) string
        %
        options.TimeRow (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.DateFormat (1, 1) string = "sdmx"
        options.Trim (1, 1) logical = true
        options.Sheet (1, 1) string = ""
    end

    periodConstructorDispatcher = struct( ...
        lower("sdmx"), @datex.fromSdmx ...
        , lower("legacy"), @datex.fromLegacy ...
    );

    periodConstructor = periodConstructorDispatcher.(lower(options.DateFormat));

    extras = {};
    if fileType == "spreadsheet" && ~isempty(options.Sheet) && options.Sheet ~= ""
        extras = [extras, "sheet", options.Sheet];
    end

    t = readtable(fileName, "fileType", fileType, "textType", "string", extras{:});

    [tt, freq] = tablex.fromTable( ...
        t ...
        , timeRow=options.TimeRow ...
        , frequency=options.Frequency ...
        , periodConstructor=periodConstructor ...
        , trim=options.Trim ...
    );

end%

