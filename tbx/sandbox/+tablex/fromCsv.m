
function tt = fromCsv(filename, options)

    arguments
        filename (1, 1) string
        options.TimeRow (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.DateFormat (1, 1) string = "sdmx"
        options.Trim (1, 1) logical = true
    end

    periodConstructorDispatcher = struct( ...
        lower("sdmx"), @datex.fromSdmx ...
        , lower("legacy"), @datex.fromLegacy ...
    );

    periodConstructor = periodConstructorDispatcher.(lower(options.DateFormat));

    t = readtable(filename, textType="string");

    [tt, freq] = tablex.fromTable( ...
        t ...
        , timeRow=options.TimeRow ...
        , frequency=options.Frequency ...
        , periodConstructor=periodConstructor ...
        , trim=options.Trim ...
    );

end%

