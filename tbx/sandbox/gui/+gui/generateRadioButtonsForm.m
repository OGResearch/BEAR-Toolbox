
function lines = generateRadioButtonsForm(settings, selectionName, currentSelection, action)

    arguments
        settings (1, 1) struct
        selectionName (1, 1) string
        currentSelection (1, 1) string
        action (1, 1) string
    end

    fieldNames = sort(textual.fields(settings));

    lines = string.empty(0, 1);
    lines(end+1) = "<form action='matlab:" + action + " '>";
    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit'>";
    lines(end+1) = "<br/><br/>";

    for n = fieldNames
        checked = "";
        if isequal(n, currentSelection)
            checked = "checked";
        end
        % lines(end+1) = "<input type='radio' id='" + n + "' name='" + name + "' value=true " + checked + ">&nbsp;";
        lines(end+1) = sprintf("<input type='radio' id='%s' name='%s' value='%s' %s>&nbsp;", n, selectionName, n, checked);
        lines(end+1) = "<label for='" + n + "'>" + n + "</label><br/>";
    end

    lines(end+1) = "<br/>";
    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit'>";
    lines(end+1) = "</form>";

    lines = join(lines, newline());

end%

