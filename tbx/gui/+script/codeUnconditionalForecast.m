
function code = codeUnconditionalForecast(taskSelection)

    if ~taskSelection.UnconditionalForecast
        code = string.empty(0, 1);
        return
    end

    TASK_FORM_PATH = {"tasks", "unconditional"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place = struct();
    place.FORECAST_SPAN = mts.span(taskSettings.ForecastSpan.value);
    place.STOCHASTIC_RESIDUALS = mts.logical(taskSettings.StochasticResiduals.value);
    place.INCLUDE_INITIAL = mts.logical(taskSettings.IncludeInitial.value);

    place = script.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = script.readTemplate("unconditionalForecast");
    code = script.replaceInCode(code, place);

end%

