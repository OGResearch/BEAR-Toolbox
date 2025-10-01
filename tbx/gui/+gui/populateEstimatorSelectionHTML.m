
function outputFile = populateEstimatorSelectionHTML()

    estimatorCategories = gui.readSettingsFile("estimatorCategories");
    currentSelection = gui.querySelection("Estimator");

    form = gui.generateCategorizedButtons(estimatorCategories, "Estimator", currentSelection, "gui_collectEstimatorSelection");

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    endPath = {"html", "estimation", "selection.html"};
    inputFile = fullfile(guiFolder, endPath{:});
    outputFile = fullfile(".", endPath{:});

    if currentSelection == ""
        currentSelection = "[No estimator selected]";
    end

    gui.changeHtmlFile( ...
        inputFile, outputFile, ...
        "$ESTIMATOR_LIST", form, ...
        "$SELECTED_ESTIMATOR", currentSelection ...
    );

end%

