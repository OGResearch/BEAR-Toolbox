
function createModuleMapping()

    FOLDER = {"gui", "forms", "module"};
    FILE_PATH = getAbsolutePath(FOLDER{:}, "mapping.json");

    disp("Creating module mapping...");

    modules = docgen.getModules();
    mapping = struct();
    for module = modules
        [~, shortNames] = docgen.getConcreteClasses(module + ".estimator");
        for shortName = shortNames
            disp("    " + shortName + "-->" + module);
            mapping.(shortName) = module;
        end
    end

    json.write(mapping, FILE_PATH, prettyPrint=true);

end%

