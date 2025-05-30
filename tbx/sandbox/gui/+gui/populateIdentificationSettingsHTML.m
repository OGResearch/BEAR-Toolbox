
function targetPath = populateIdentificationSettingsHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    identificationSelection = gui.querySelection("Identification");

    exactZerosTableURL = "file://localhost/" + fullfile(string(pwd()), "table", "ExactZeros.xslx");
    xxx = "file://localhost//Users/myself/Documents/ogr-external-projects/ecb-bear/BEAR-toolbox/tbx/gui_poc/tables/ExactZeros.xlsx";
    % xxx = "<a href='file://localhost//Users/myself/Documents/ogr-external-projects/ecb-bear/BEAR-toolbox/tbx/gui_poc/tables/ExactZeros.xlsx'>Exact Zeros Table</a>";

    sourcePath = fullfile(guiFolder, "html", "identification_settings.html");
    targetPath = fullfile(".", "html", "identification_settings.html");
    % TODO: $IDENTIFICATION_CONTENT --> $IDENTIFICATION_SELECTION_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$XXX", xxx);

end%
