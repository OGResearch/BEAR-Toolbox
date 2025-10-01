
function gui_selectInputDataFile()

    % Read the existing form
    FORM_PATH = {"data", "source"};
    jsonForm = gui.readFormsFile(FORM_PATH);

    FILTER = ["*.csv"; "*.xls"; "*.xlsx"];
    PROMPT = "Select input data file";

    [inputDataFileName, inputDataFilePath] = uigetfile(FILTER, PROMPT);

    if isequal(inputDataFileName, 0) || isequal(inputDataFilePath, 0)
        return
    end
    filePath = string(fullfile(inputDataFilePath, inputDataFileName));
    submission = struct(FilePath=filePath);
    jsonForm = gui.updateValuesFromSubmission(jsonForm, submission);

    % Write the updated form back to the JSON file
    gui.writeFormsFile(jsonForm, FORM_PATH);

    targetPage = gui.populateDataSourceHTML();
    web(targetPage);

end%

