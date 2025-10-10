
function code = assemble(options)

    arguments
        options.saveToFile (1, 1) string = ""
    end

    taskSelection = gui.getCurrentTaskSelection();

    snippets = string.empty(0, 1);

    snippets = [snippets; script.codePreamble()];

    snippets = [snippets; script.codeReducedFormModel()];

    snippets = [snippets; script.codeReducedFormEstimation(taskSelection)];

    snippets = [snippets; script.codeStructuralEstimation(taskSelection)];

    snippets = [snippets; script.codeUnconditionalForecast(taskSelection)];

    % snippets = [snippets; script.codeConditionalForecast(taskSelection)];

    code = join(snippets, "");

    if options.saveToFile ~= ""
        textual.write(code, options.saveToFile);
    end

end%

