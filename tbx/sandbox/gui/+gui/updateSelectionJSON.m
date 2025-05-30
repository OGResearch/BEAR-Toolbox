
function updateSelectionJSON(update)

    arguments
        update (1, 1) struct
    end

    selectionPath = fullfile("settings", "selection.json");
    selection = jsondecode(fileread(selectionPath));

    for key = textual.fields(update)
        value = update.(key);
        if ~isfield(selection, key)
            error("This key '%s' does not exist in selection.json", key);
        end
        selection.(key) = string(value);
    end

    writematrix( ...
        jsonencode(selection, PrettyPrint=true), ...
        selectionPath, ...
        fileType="text", ...
        quoteStrings=false ...
    )

end%

