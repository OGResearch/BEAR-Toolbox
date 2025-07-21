
function gui_collectIdentificationSelection(submission)

    arguments
        submission (1, 1) string
    end

    submission = gui.resolveRawFormSubmission(submission);
    selectedIdentification = submission.Identification;
    gui.updateSelection(Identification=selectedIdentification);

    identificationSettingsPath = gui.populateIdentificationSettingsHTML();
    web(identificationSettingsPath);

end%

