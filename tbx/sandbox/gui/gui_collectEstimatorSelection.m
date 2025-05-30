
function gui_collectEstimatorSelection(submission)

    arguments
        submission (1, 1) string
    end

    selection = gui.resolveRawFormSubmission(submission);
    gui.updateSelectionJSON(selection);

    estimatorSettingsPath = gui.populateEstimatorSettingsHTML();
    web(estimatorSettingsPath);

end%

