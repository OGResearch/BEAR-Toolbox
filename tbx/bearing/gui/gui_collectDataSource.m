
function gui_collectDataSource(submission)

    arguments
        submission (1, 1) string
    end

    dataSource = gui.readSettingsFile("dataSource");
    submission = gui.resolveCleanFormSubmission(submission, dataSource);
    dataSource = gui.updateValuesFromSubmission(dataSource, submission);
    gui.writeSettingsFile(dataSource, "dataSource", PrettyPrint=true);

    currentHTML = gui.populateDataSourceHTML();
    web(currentHTML);

end%

