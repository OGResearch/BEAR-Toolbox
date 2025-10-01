
function createEstimatorSelectionForm()

    FOLDER = {"gui", "forms", "estimation"};
    FILE_PATH = getAbsolutePath(FOLDER{:}, "selection.json");

    disp("Creating estimator selection form...");

    modules = docgen.getModules();
    selection = struct();
    for module = modules
        [qualifiedEstimatorNames, shortNames] = docgen.getConcreteClasses(module + ".estimator");
        for i = 1 : numel(shortNames)
            cl = eval(qualifiedEstimatorNames(i));
            category = cl.Category;
            disp("    " + qualifiedEstimatorNames(i) + "-->" + category);
            selection.(shortNames(i)) = struct( ...
                category=category, ...
                value=false ...
            );
        end
    end

    json.write(selection, FILE_PATH, prettyPrint=true);

end%

