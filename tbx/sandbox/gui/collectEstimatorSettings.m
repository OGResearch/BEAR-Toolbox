
function collectEstimatorSettings(submission)

    arguments
        submission (1, 1) string
    end

    estimatorSettingsPath = gui.populateEstimatorSettingsHTML();
    web(estimatorSettingsPath);

end%

