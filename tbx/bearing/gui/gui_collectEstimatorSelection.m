
function gui_collectEstimatorSelection(submission)

    arguments
        submission (1, 1) string
    end

    % Handle estimator selection
    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    gui.updateSelection({"estimation", "selection"}, newSelection);
    tagetPage = gui.populateEstimatorSelectionHTML();

    % Determine and save the new module
    moduleMapping = gui.readFormsFile({"module", "mapping"});
    newModule = moduleMapping.(newSelection);
    gui.writeFormsFile(newModule, {"module", "selection"});

    % Prepare meta settings page
    gui.populateMetaSettingsHTML();

    % Prepare dummies selection page
    gui.populateDummiesSelectionHTML();

    % Prepare structural identification selection page
    gui.populateIdentificationSelectionHTML();
    % gui.populateVanillaFormHTML({"identification", "cholesky"});

    % Prepare estimator settings page
    targetPage = gui.populateEstimatorSettingsHTML();

    % Move on to the meta settings page
    web(targetPage);

end%

