
function code = assemble(options)

    arguments
        options.saveToFile (1, 1) string = ""
    end

    prerequisites = gui.getCurrentPrerequisites();
    module = gui.getCurrentModule();
    estimator = gui.getCurrentEstimator();
    estimatorSettings = gui.getCurrentEstimatorSettings();
    metaSettings = gui.getCurrentMetaSettings();
    dataSource = gui.getCurrentDataSource();

    snippets = string.empty(0, 1);

    snippets(end+1) = script.codePreamble( ...
        prerequisites=prerequisites ...
    );

    snippets(end+1) = script.codeReducedFormModel( ...
        module=module ...
        , metaSettings=metaSettings ...
        , dataSource=dataSource ...
        , estimator=estimator ...
        , estimatorSettings=estimatorSettings ...
    );

    code = join(snippets, "");

    if options.saveToFile ~= ""
        textual.write(code, options.saveToFile);
    end

end%

