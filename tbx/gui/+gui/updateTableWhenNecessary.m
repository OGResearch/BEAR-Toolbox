
function updateTableWhenNecessary(options)

    arguments
        options.RowNames (1, :) string
        options.ColumnNames (1, :) string
        options.FileName (1, 1) string
        options.Title (1, 1) string
        options.WriteMode (1, 1) = "overwritesheet"
    end

    guiFolder = gui_getFolder();
    guiTablesFolder = fullfile(guiFolder, "tables");
    customTablesFolder = fullfile(".", "tables");
    sourceFile = fullfile(guiTablesFolder, options.FileName);
    targetFile = fullfile(customTablesFolder, options.FileName);

    if ~needsUpdate_(targetFile, options.RowNames, options.ColumnNames)
        disp("No need to update " + targetFile);
        return
    end

    disp("Updating " + targetFile);

    numRows = numel(options.RowNames);
    numColumns = numel(options.ColumnNames);
    update = repmat("", numRows+1, numColumns+1);
    update(1, 1) = options.Title;
    update(1, 2:end) = options.ColumnNames;
    update(2:end, 1) = transpose(options.RowNames);

    copyfile(sourceFile, targetFile);
    writematrix( ...
        update, targetFile ...
        , fileType="spreadsheet" ...
        , writeMode=options.WriteMode ...
    );

end%


function out = needsUpdate_(targetFile, rowNames, columnNames)

    if ~isfile(targetFile)
        out = true;
        return
    end

    existingTable = readmatrix( ...
        targetFile ...
        , fileType="spreadsheet" ...
        , outputType="string" ...
    );

    numRows = numel(rowNames);
    numColumns = numel(columnNames);
    if size(existingTable, 1) ~= numRows + 1 || size(existingTable, 2) ~= numColumns + 1
        out = true;
        return
    end

    if any(reshape(existingTable(2:end, 1), 1, []) ~= rowNames)
        out = true;
        return
    end

    if any(reshape(existingTable(1, 2:end), 1, []) ~= columnNames)
        out = true;
        return
    end

    out = false;

end%

