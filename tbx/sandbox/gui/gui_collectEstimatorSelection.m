
function gui_collectEstimatorSelection(submission)

    arguments
        submission (1, 1) string
    end

    submission = gui.resolveRawFormSubmission(submission);
    selectedEstimator = submission.Estimator;
    gui.updateSelection(Estimator=selectedEstimator);

    allEstimatorSettings = gui.readSettingsFile("estimatorSettings");
    estimatorSettings = allEstimatorSettings.(selectedEstimator);
    gui.updateSelection(EstimatorSettings=estimatorSettings);
    gui.populateEstimatorSelectionHTML();

    estimatorSettingsPath = gui.populateEstimatorSettingsHTML();
    web(estimatorSettingsPath);

end%

