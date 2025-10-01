
function selected = querySelection(topic)

    arguments
        topic (1, 1) string
    end

    selection = gui.readSettingsFile("selection");

    if ~isfield(selection, topic)
        error("Topic '%s' does not exist in selection.json", topic);
    end

    selected = selection.(topic);

end%

