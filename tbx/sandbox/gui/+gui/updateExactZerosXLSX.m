
function updateExactZerosXLSX()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    guiTablesFolder = fullfile(guiFolder, "tables");
    userTablesFolder = fullfile(".", "tables");

    copyfile( ...
        fullfile(guiTablesFolder, "ExactZeros.xlsx"), ...
        fullfile(userTablesFolder, "ExactZeros.xlsx") ...
    )

    meta = json.read(fullfile(".", "settings", "metaSettings.json"));
    endogenousConcepts = meta.EndogenousConcepts.value;
    residualPrefix = meta.ResidualPrefix.value;

    numEndogenous = numel(endogenousConcepts);
    update = repmat("", numEndogenous+1, numEndogenous+1);
    update(1, 1) = "Exact Zero Restrictions";
    update(1, 2:end) = residualPrefix + "_" + endogenousConcepts;
    update(2:end, 1) = transpose(endogenousConcepts);

    writematrix( ...
        update, fullfile(userTablesFolder, "ExactZeros.xlsx") ...
        , fileType="spreadsheet" ...
        , writeMode="inplace" ...
    );

end%

