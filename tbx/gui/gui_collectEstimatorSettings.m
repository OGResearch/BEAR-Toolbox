
function gui_collectEstimatorSettings(submission)

    arguments
        submission (1, 1) string
    end

    estimatorSettings = gui.querySelection("EstimatorSettings");

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    cleanSubmission = gui.resolveCleanFormSubmission(submission, estimatorSettings);
    estimatorSettings = gui.updateValuesFromSubmission(estimatorSettings, cleanSubmission);

    % Update the estimator settings JSON with the new values
    gui.updateSelection(EstimatorSettings=estimatorSettings);

    % Repopulate the HTML with the cleaned-up settings
    currentHTML = gui.populateEstimatorSettingsHTML();
    web(currentHTML);

end%

