
function gui_collectMetaSettings(submission)

    arguments
        submission (1, 1) string
    end

    TARGET_PAGE = {"identification", "selection.html"};

    % Determine the current module and the path to the corresponding meta
    % settings form
    currentModule = gui.getCurrentModule();
    settingsPath = {"meta", currentModule};

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    settingsForm = gui.readFormsFile(settingsPath);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, settingsForm);
    settingsForm = gui.updateValuesFromSubmission(settingsForm, cleanSubmission);

    % Update the meta settings JSON with the new values
    gui.writeFormsFile(settingsForm, settingsPath);

    % Update tables
    metaObject = eval(currentModule + ".Meta()");
    [~, cellValues] = gui.extractValuesFromForm(settingsForm);
    metaObject.update(cellValues{:});
    gui.updateExactZerosXLSX(metaObject);
    gui.updateInequalityXLSX(metaObject);

    % Repopulate the structural identification selection page
    % gui.populateIdentificationSelectionHTML();

    % Repopulate the HTML with the cleaned-up settings
    gui.populateMetaSettingsHTML();

    % Move on to the structural identification selection page
    targetPage = fullfile(".", "html", TARGET_PAGE{:});
    web(targetPage);

end%

