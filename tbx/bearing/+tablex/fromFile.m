
function [tt, freq, tbl] = fromFile(fileName, options)

    arguments
        fileName (1, 1) string
        %
        options.FileType (1, 1) string = ""
        options.TimeColumn (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.DateFormat (1, 1) string = "sdmx"
        options.Trim (1, 1) logical = true
        options.Sheet = 1
        %
        options.ConvertTo = []
        options.ReplaceMissing (1, 1) logical = true
    end

    option.FileType = tryAutoDetectFileType__(options.FileType, fileName);

    periodConstructorDispatcher = struct( ...
        lower("sdmx"), @datex.fromSdmx ...
        , lower("legacy"), @datex.fromLegacy ...
    );

    periodConstructor = periodConstructorDispatcher.(lower(options.DateFormat));

    args = {
        "textType", "string" ...
    };
    if options.FileType ~= ""
        args = [args, {"fileType", options.FileType}];
    end
    if ~isempty(options.Sheet) && ~isequal(options.Sheet, 1)
        args = [args, {"sheet", options.Sheet}];
    end

    tbl = readtable(fileName, args{:});

    if ~isempty(options.ConvertTo)
        tbl = tablex.convert(tbl, options.ConvertTo);
    end

    if options.ReplaceMissing
        tbl = tablex.replaceMissing(tbl);
    end

    [tt, freq] = tablex.fromTable( ...
        tbl ...
        , timeColumn=options.TimeColumn ...
        , frequency=options.Frequency ...
        , periodConstructor=periodConstructor ...
        , trim=options.Trim ...
    );

end%


function fileType = tryAutoDetectFileType__(fileType, fileName)
    %[
    FILETYPES = struct( ...
        xlsx="spreadsheet" ...
        , xls="spreadsheet" ...
        , csv="text" ...
        , txt="text" ...
    );
    %
    if fileType == ""
        [~, ~, fileExt] = fileparts(fileName);
        fileExt = extractAfter(string(fileExt), ".");
        try
            fileType = FILETYPES.(lower(fileExt(2:end)));
        catch
            % Do nothing
        end
    end
    %]
end%

