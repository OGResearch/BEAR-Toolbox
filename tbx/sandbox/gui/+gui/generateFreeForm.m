
function outputString = generateFreeForm(inputStruct, options)

    arguments
        inputStruct (1, 1) struct
        %
        options.header (1, 1) string = ""
        options.action (1, 1) string = ""
    end

    ELEMENT_CREATORS = struct(...
        name=@createTextField_, ...
        names=@createTextField_, ...
        string=@createTextField_, ...
        number=@createTextField_, ...
        numbers=@createTextField_, ...
        date=@createTextField_, ...
        logical=@createCheckbox_, ...
        logicals=@createTextField_, ...
        dates=@createTextField_, ...
        span=@createTextField_, ...
        filename=@createFile_ ...
    );

    mtf = gui.MatlabToForm;

    submitButton = gui.generateSubmitButton();

    fieldNames = sort(textual.fields(inputStruct));

    lines = string.empty(1, 0);

    if strlength(options.header) > 0
        lines(end+1) = "<h2>" + options.header + "</h2>";
    end

    lines(end+1) = "<form action='matlab:" + options.action + " '>";
    lines(end+1) = submitButton;
    lines(end+1) = "<br/>";
    lines(end+1) = "<br/>";

    for n = fieldNames
        item = inputStruct.(n);
        if isfield(item, "show") && isequal(item.show, false)
            continue
        end
        type = item.type;
        matlabValue = item.value;
        formValue = mtf.(type)(matlabValue);
        elementCreator = ELEMENT_CREATORS.(type);
        elementLines = elementCreator(n, formValue);
        lines = [lines, elementLines];
    end

    lines(end+1) = "<br/>";
    lines(end+1) = submitButton;
    lines(end+1) = "</form>";

    outputString = join(lines, newline());

end%


function lines = createTextField_(name, value)
    lines = join([
        "<label for='{NAME}'>{NAME}</label><br/>"
        "<input style='color:black; background-color:lightgray' type='text' id='{NAME}' name='{NAME}' value='{VALUE}'><br/>"
    ], newline());
    lines = replace(lines, "{NAME}", name);
    lines = replace(lines, "{VALUE}", value);
end%


function lines = createFile_(name, value)
    lines = join([
        "<label for='{NAME}'>{NAME}</label><br/>"
        "<input style='color:black; background-color:lightgray' type='file' id='{NAME}' name='{NAME}' value='{VALUE}'><br/>"
    ], newline());
    lines = replace(lines, "{NAME}", name);
    lines = replace(lines, "{VALUE}", value);
end%


function lines = createCheckbox_(name, value)
    lines = string.empty(0, 1);
    checked = "";
    if gui.isTrue(value)
        checked = "checked";
    end
    lines(end+1) = sprintf("<input type='checkbox' id='%s' name='%s' value='true' %s>&nbsp;", name, name, checked);
    lines(end+1) = sprintf("<label for='%s'>%s</label><br/>", name, name);
end%

