function outputString = createForm(inputStruct, options)
    arguments
        inputStruct struct
        options.header (1,1) string = ""
        options.submitText (1,1) string = "Submit"
        options.action (1,1) string = ""
    end
% Create a string representation of a table from a structure. To be used in HTML
    
    mtf = gui.MatlabToForm;

    lines = string.empty(0, 1);
    fieldNames = fieldnames(inputStruct);
    numFields = numel(fieldNames);
    if numFields == 0
        outputString = "No data available.";
        return;
    end

    fieldNames = textual.stringify(fieldNames);
    fieldNames = sort(fieldNames);

    lines(end+1) = "<h2>"+options.header+"</h2>";
    lines(end+1) = "<form action='matlab:" + options.action + " '>";
    % lines(end+1) = "<thead>";
    % lines(end+1) = "<tr>";
    % lines(end+1) = "<th>Name</th>";
    % lines(end+1) = "</tr>";
    % lines(end+1) = "</thead>";
    % lines(end+1) = "<tbody>";
    % Iterate over field names to create table rows
    for i = 1:numFields
        fieldName = fieldNames{i};
        lines(end+1) = "<label for='" + fieldName + "'>" + fieldName + "</label><br>";
        Value = inputStruct.(fieldName).value;
%         if isempty(Value)
%             Value = "";
%         end
        if strcmpi(inputStruct.(fieldName).type,"logical")
            check_string = "";
            if islogical(Value)
                if Value
                    check_string = "checked"; 
                end
            elseif strcmpi(Value, "true")
                check_string = "checked";
            end
            % If the field is a boolean, create a checkbox
            lines(end+1) = "<input type='checkbox' id='" + fieldName + "' name='" + fieldName + "' value='true' " + check_string + "><br>";
        else
            lines(end+1) = "<input style='color:black' type='text' id='" + fieldName + "' name='" + fieldName + "' value='" + mtf.(inputStruct.(fieldName).type)(Value) + "'><br>";
        end
    end
    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit' value='" + options.submitText + "'>";
    % lines(end+1) = "</tbody>";
    lines(end+1) = "</form>";
    % lines(end+1) = "<a href='matlab:gui.collectUserData()'>Process user inputs</a></p>";
    
    outputString = join(lines, newline());
end