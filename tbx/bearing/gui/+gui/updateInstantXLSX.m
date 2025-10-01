
function updateInstantXLSX(meta, fileName, title)

    guiFolder = gui_getFolder();
    guiTablesFolder = fullfile(guiFolder, "tables");
    customTablesFolder = fullfile(".", "tables");

    sourceFile = fullfile(guiTablesFolder, fileName);
    targetFile = fullfile(customTablesFolder, fileName);

    copyfile(sourceFile, targetFile);

    endogenous = meta.getSeparableEndogenousNames();
    shocks = meta.getSeparableShockNames();

    numEndogenous = numel(endogenous);
    update = repmat("", numEndogenous+1, numEndogenous+1);
    update(1, 1) = title;
    update(1, 2:end) = shocks;
    update(2:end, 1) = transpose(endogenous);

    writematrix( ...
        update, targetFile ...
        , fileType="spreadsheet" ...
        ... , writeMode="inplace" ...
        , writeMode="overwritesheet" ...
    );

end%

