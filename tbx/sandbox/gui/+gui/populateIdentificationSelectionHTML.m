
function populateIdentificationSelectionHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    userSettingsFolder = "settings";
    gui.createFolder(userSettingsFolder);

    identifications = struct();
    identifications.Cholesky = struct();
    identifications.ExactZero = struct();

    currentSelection = gui.querySelection("Identification");
    form = gui.generateRadioButtonsForm(identifications, "Identification", currentSelection, "collectIdentificationSelection");

    inputFile = fullfile(guiFolder, "html", "identifications.html");
    outputFile = fullfile(".", "html", "identifications.html");
    % TODO: $IDENTIFICATION_CONTENT --> $IDENTIFICATION_SELECTION_FORM
    gui.changeHtmlFile(inputFile, outputFile, "$IDENTIFICATION_CONTENT", form);

end%
