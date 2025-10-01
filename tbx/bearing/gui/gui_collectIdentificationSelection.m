
function gui_collectIdentificationSelection(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"identification", "selection"};

    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    selectionForm = gui.updateSelection(FORM_PATH, newSelection);
    gui.populateIdentificationSelectionHTML();

    % Move on the corresponding identification page
    guiFolder = gui_getFolder();
    targetPage = selectionForm.(newSelection).target;
    targetPage = cellstr(targetPage);
    targetPage = fullfile(".", "html", targetPage{:}) + ".html";
    web(targetPage);

end%

