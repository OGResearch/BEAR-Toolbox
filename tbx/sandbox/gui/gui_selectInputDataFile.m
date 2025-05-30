
function gui_selectInputDataFile()

    FILTER = ["*.csv"; "*.xls"; "*.xlsx"];
    PROMPT = "Select an input data file";

    [fileName, filePath] = uigetfile(FILTER, PROMPT);

    if isequal(fileName, 0) || isequal(filePath, 0)
        return
    end

    gui.updateSelectionJSON(struct(InputDataFile=string(fileName)));
    inputDataPath = gui.populateInputDataHTML();
    web(inputDataPath);

end%

