
function selected = querySelection(topic)

    arguments
        topic (1, 1) string
    end

    selectionPath = fullfile("settings", "selection.json");
    selection = jsondecode(fileread(selectionPath));

    if ~isfield(selection, topic)
        error("Topic '%s' does not exist in selection.json", topic);
    end

    selected = string(selection.(topic));

end%

