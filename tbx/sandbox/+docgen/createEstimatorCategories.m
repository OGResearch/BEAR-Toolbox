
function createEstimatorCategories()

    FOLDER = {"gui", "forms", "estimation"};
    CATEGORIES_FILE_PATH = getAbsolutePath(FOLDER{:}, "categories.json");
    SELECTION_FILE_PATH = getAbsolutePath(FOLDER{:}, "selection.json");

    disp("Creating estimator categories...");

    orderedCategories = [
        "Plain estimators", ...
        "Time-varying estimators", ...
    ];

    selection = json.read(SELECTION_FILE_PATH);
    checkCategories = string.empty(1, 0);
    for n = textual.fields(selection)
        checkCategories(end+1) = selection.(n).category;
    end
    checkCategories = unique(checkCategories);

    if isequal(sort(orderedCategories), sort(checkCategories))
        error("Categories in selection.json do not match ordered categories.");
    end

    for n = orderedCategories
        disp("    " + n);
    end

    orderedCategories = cellstr(orderedCategories);
    json.write(orderedCategories, CATEGORIES_FILE_PATH, prettyPrint=true);

end%

