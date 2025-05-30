
function outputString = createForm(inputStruct, options)

    arguments
        inputStruct struct
        options.header (1, 1) string = ""
        options.submitText (1, 1) string = "Submit"
        options.action (1, 1) string = ""
    end

    ELEMENT_CREATORS = struct(...
        name=@createTextField_, ...
        names=@createTextField_, ...
        string=@createTextField_, ...
        number=@createTextField_, ...
        numbers=@createTextField_, ...
        date=@createTextField_, ...
        logical=@createCheckbox_ ...
    );

    mtf = gui.MatlabToForm;

    fieldNames = sort(textual.fields(inputStruct));

    lines = string.empty(1, 0);

    if strlength(options.header) > 0
        lines(end+1) = "<h2>" + options.header + "</h2>";
    end

    lines(end+1) = "<form action='matlab:" + options.action + " '>";

    for n = fieldNames
        type = inputStruct.(n).type;
        matlabValue = inputStruct.(n).value;
        formValue = mtf.(type)(matlabValue);
        elementCreator = ELEMENT_CREATORS.(type);
        elementLines = elementCreator(n, formValue);
        lines = [lines, elementLines];
    end

    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit' value='" + options.submitText + "'>";
    lines(end+1) = "</form>";

    outputString = join(lines, newline());

end%


function lines = createTextField_(name, value)
    lines = string.empty(0, 1);
    lines(end+1) = sprintf("<label for='%s'>%s</label><br/>", name, name);
    lines(end+1) = sprintf("<input style='color:black' type='text' id='%s' name='%s' value='%s'><br/>", name, name, value);
end%


function lines = createCheckbox_(name, value)
    lines = string.empty(0, 1);
    checked = "";
    if value
        checked = "checked";
    end
    lines(end+1) = sprintf("<input type='checkbox' id='%s' name='%s' value='true' %s>&nbsp;", name, name, checked);
    lines(end+1) = sprintf("<label for='%s'>%s</label><br/>", name, name);
end%

