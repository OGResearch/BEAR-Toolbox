function updateEstimatorSelectPage(input_file,output_file, inputStruct)

    % Check if input_file and output_file are provided
    if nargin < 3
        error('Input file, output file, and inputStruct must be provided.');
    end

    % Generate the HTML content for the estimator selection page
    lines = string.empty(0, 1);
    fieldNames = fieldnames(inputStruct);
    numFields = numel(fieldNames);
    if numFields == 0
        outputString = "No data available.";
        return;
    end
    fieldNames = textual.stringify(fieldNames);
    fieldNames = sort(fieldNames);
    lines(end+1) = "<h2>Select Estimator:</h2>";
    lines(end+1) = "<form action='matlab:collectEstimator '>";
    % TODO: hardcode to only 4 estimators for now
    for i = 1:4 %numFields
        fieldName = fieldNames{i};
        lines(end+1) = "<label for='" + fieldName + "'>" + fieldName + "</label><br>";
        lines(end+1) = "<input type='radio' id='" + fieldName + "' name='" + fieldName + "' value=" + fieldName + "><br>";
    end
    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit' value='Select Estimator'>";
    lines(end+1) = "</form>";

    estimatorList = join(lines, newline());

    % updateMetaPage - Update the metadata page in the User folder
    gui.changeHtmlFile(input_file,output_file, "$ESTIMATOR_LIST", estimatorList);
end