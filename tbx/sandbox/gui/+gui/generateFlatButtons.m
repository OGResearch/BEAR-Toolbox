
function lines = generateFlatButtons(choices, context, currentSelection, action, type)

    arguments
        choices (1, 1) struct
        context (1, 1) string
        currentSelection (1, :) string
        action (1, 1) string
        type (1, 1) string = "radio"
    end

    lines = string.empty(0, 1);
    lines(end+1) = "<form action='matlab:{ACTION}'>";

    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit'>";
    lines(end+1) = "<br/><br/>";

    for name = textual.fields(choices)
        checked = "";
        if ismember(name, currentSelection)
            checked = "checked";
        end
        lines(end+1) = "<input type='{TYPE}' id='{NAME}' name='{CONTEXT}' value='{NAME}' {CHECKED}>&nbsp;";
        lines(end+1) = "<label for='{NAME}'>{NAME}</label><br/>";
        lines = replace(lines, "{NAME}", name);
        lines = replace(lines, "{CONTEXT}", context);
        lines = replace(lines, "{CHECKED}", checked);
    end

    lines(end+1) = "<br/>";
    lines(end+1) = "<input style='color:black' style='background-color:gray' type='submit'>";
    lines(end+1) = "</form>";

    lines = replace(lines, "{ACTION}", action);
    lines = replace(lines, "{TYPE}", type);

    lines = join(lines, newline());

end%

