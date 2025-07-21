
function gui_selectInputDataFile()

    FILTER = ["*.csv"; "*.xls"; "*.xlsx"];
    PROMPT = "Select input data file";

    [fileName, filePath] = uigetfile(FILTER, PROMPT);

    if isequal(fileName, 0) || isequal(filePath, 0)
        return
    end

    fullFilePath = fullfile(filePath, fileName);

    dataSource = gui.readSettingsFile("dataSource");
    dataSource.FileName.value = fullFilePath;
    gui.writeSettingsFile(dataSource, "dataSource", PrettyPrint=true);

    currentHTML = gui.populateDataSourceHTML();
    web(currentHTML);

end%

