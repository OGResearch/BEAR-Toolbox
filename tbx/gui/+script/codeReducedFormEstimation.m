
function code = codeReducedFormEstimation(taskSelection)

    if ~taskSelection.ReducedFormEstimation
        code = string.empty(0, 1);
        return
    end

    TASK_FORM_PATH = {"tasks", "estimation"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);

    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place.NUM_SAMPLES = mts.number(taskSettings.NumSamples.value);

    % Create the code from the template
    code = script.readTemplate("reducedFormEstimation");
    code = script.replaceInCode(code, place);

end%

