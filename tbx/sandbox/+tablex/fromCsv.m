%{{{ +tablex/fromCSV
%
% `fromCSV`
% ==========
%
% Read a CSV file and convert it to a time table
%
%     tt = tablex.fromCsv(filename, ___)
%
%
% Input arguments
% ----------------
%
% * `filename`:  Name of the CSV file to read
%
%
% Options
% --------
%
% * `timeRow="Time"`: Name of the column in the CSV file that will be used as
% the time column.
%
% * `frequency=NaN`: Time frequency as an integer; one of 1, 2, 4, 6, 12, 52, 365.
%
% * `dateFormat="sdmx"`: Date format in the time column; one of "sdmx" or
% "legacy".
%
%
% Output arguments
% -----------------
%
% * `tt`: Time table created from the CSV file.
%
%}}}

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

