
function populateIdentificationSelectionHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    userSettingsFolder = "settings";
    gui.createFolder(userSettingsFolder);

    identifications = struct();
    identifications.Cholesky = struct();
    identifications.ExactZero = struct();

    currentSelection = gui.querySelection("Identification");
    form = gui.generateRadioButtonsForm(identifications, "Identification", currentSelection, "collectIdentificationSelection");

    inputFile = fullfile(guiFolder, "html", "identification_selection.html");
    outputFile = fullfile(".", "html", "identification_selection.html");
    % TODO: $IDENTIFICATION_CONTENT --> $IDENTIFICATION_SELECTION_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$IDENTIFICATION_CONTENT", form);

end%

