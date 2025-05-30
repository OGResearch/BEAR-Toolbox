
function collectIdentificationSelection(submission)

    arguments
        submission (1, 1) string
    end

    selection = gui.resolveRawFormSubmission(submission);
    gui.updateSelectionJSON(selection);

    identificationSettingsPath = gui.populateIdentificationSettingsHTML();
    web(identificationSettingsPath);

end%

