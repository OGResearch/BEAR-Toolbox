
function code = codeStructuralEstimation(taskSelection)

    if ~taskSelection.StructuralEstimation
        code = string.empty(0, 1);
        return
    end

    TASK_FORM_PATH = {"tasks", "identification"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);

    module = gui.getCurrentModule();
    identifier = gui.getCurrentIdentifier();
    identifierSettings = gui.getCurrentIdentifierSettings();

    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place.IDENTIFIER = string(identifier);
    place.IDENTIFIER_SETTINGS = script.printFormAsSettings(identifierSettings);
    place.NUM_SAMPLES = mts.number(taskSettings.NumSamples.value);

    place = script.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = script.readTemplate("structuralEstimation");
    code = script.replaceInCode(code, place);

end%
