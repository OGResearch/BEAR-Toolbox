
function populateTaskSelectionHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    taskSelection = gui.readSettingsFile("taskSelection");

    form = gui.generateFlatButtons( ...
        taskSelection.Choices ...
        , "TaskSelection" ...
        , taskSelection.Selection ...
        , "gui_collectTaskSelection" ...
        , "checkbox" ...
    );

    endPath = {"html", "tasks", "selection.html"};
    inputFile = fullfile(guiFolder, endPath{:});
    outputFile = fullfile(".", endPath{:});
    gui.changeHtmlFile(inputFile, outputFile, "$TASK_SELECTION", form);

end%
