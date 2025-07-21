
function updateSelection(varargin)

    if nargin == 1
        update = varargin{1};
    else
        update = struct(varargin{:});
    end

    selection = gui.readSettingsFile("selection");

    for key = textual.fields(update)
        if ~isfield(selection, key)
            error("Key '%s' does not exist in selection.json", key);
        end
        value = update.(key);
        selection.(key) = value;
    end

    gui.writeSettingsFile(selection, "selection", PrettyPrint=true);

end%

