
function targetPath = populateDataSourceHTML()

    isText = @(x) ischar(x) || isstring(x);

    FORM_PATH = {"data", "source"};
    HTML_END_PATH = {"html", "data", "source.html"};

    currentFilePath = gui.getCurrentDataFilePath();

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    if ~isText(currentFilePath) || strlength(currentFilePath) == 0
        currentFilePath = "<code>[No data file selected]</code>";
        currentList = "<code>[No data file selected]</code>";
        currentSpan = "<code>[No data file selected]</code>";
    else
        tbl = tablex.fromFile(currentFilePath);
        variableNames = tablex.getColumnNames(tbl);
        variableNames = "<li><code>" + variableNames + "</code></li>";
        currentList = join(string(variableNames), newline());
        currentList = "<ul>" + currentList + "</ul>";
        startPeriod = tablex.startPeriod(tbl);
        endPeriod = tablex.endPeriod(tbl);
        currentSpan = "<code>" + string(startPeriod) + "</code> to <code>" + string(endPeriod) + "</code>";
        currentFilePath = "<code>" + currentFilePath + "</code>";
    end

    gui.copyCustomHTML( ...
        sourcePath, targetPath ...
        , "?FILE?", currentFilePath ...
        , "?LIST?", currentList ...
        , "?SPAN?", currentSpan ...
    );

end%

