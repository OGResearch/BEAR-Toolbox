
function collectEstimatorSelection(submission)

    selection = gui.resolveRawFormSubmission(submission);
    gui.updateSelectionJSON(selection);

    gui.populateEstimatorSettingsHTML();

end%

