
function tt = fromCsv(filename, options)

    arguments
        filename (1, 1) string
        options.TimeRow (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.PeriodConstructor = @datex.fromSdmx
        options.Trim (1, 1) logical = true
    end

    t = readtable(filename, textType="string");

    [tt, freq] = tablex.fromTable( ...
        t ...
        , timeRow=options.TimeRow ...
        , frequency=options.Frequency ...
        , periodConstructor=options.PeriodConstructor ...
        , trim=options.Trim ...
    );

end%

