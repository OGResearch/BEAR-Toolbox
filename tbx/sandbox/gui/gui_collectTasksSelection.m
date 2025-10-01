
function gui_collectTasksSelection(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"tasks", "selection"};
    TARGET_PAGE = {"html", "tasks", "prerequisites.html"};

    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    gui.updateSelection(FORM_PATH, newSelection);
    gui.populateTasksSelectionHTML();

    % Move on the prerequisites page
    targetPage = fullfile(".", TARGET_PAGE{:});
    web(targetPage);

end%
