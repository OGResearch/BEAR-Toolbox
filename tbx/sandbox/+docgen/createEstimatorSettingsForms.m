
function createEstimatorSettingsForms()

    FOLDER = {"gui", "forms", "estimation"};

    disp("Creating estimator settings forms...");

    modules = docgen.getModules();

    for module = modules
        estimatorClasses = docgen.getConcreteClasses(module + ".estimator");
        for qualifiedEstimatorName = estimatorClasses
            disp("    " + qualifiedEstimatorName);
            settings = docgen.getEstimatorSettings(qualifiedEstimatorName);
            %
            nameParts = split(string(qualifiedEstimatorName), ".");
            fileTitle = nameParts(end) + ".json";
            formPath = getAbsolutePath(FOLDER{:}, fileTitle);
            json.write(settings, formPath, prettyPrint=true);
        end
    end

end%

