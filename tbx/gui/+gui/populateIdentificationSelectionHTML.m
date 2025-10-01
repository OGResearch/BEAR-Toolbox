
function populateIdentificationSelectionHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    identificationSelection = gui.readSettingsFile("identificationSelection");

    form = gui.generateFlatButtons( ...
        identificationSelection.Choices ...
        , "IdentificationSelection" ...
        , identificationSelection.Selection ...
        , "gui_collectIdentificationSelection" ...
    );

    endPath = {"html", "identification", "selection.html"};
    inputFile = fullfile(guiFolder, endPath{:});
    outputFile = fullfile(".", endPath{:});
    gui.changeHtmlFile(inputFile, outputFile, "$IDENTIFICATION_SELECTION", form);

end%
