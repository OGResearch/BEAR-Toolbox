
function targetPath = populateIdentificationSettingsHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    identificationSelection = gui.querySelection("Identification");

    exactZerosTableURL = "file://localhost/" + fullfile(string(pwd()), "table", "ExactZeros.xslx");
    xxx = "file://localhost//Users/myself/Documents/ogr-external-projects/ecb-bear/BEAR-toolbox/tbx/gui_poc/tables/ExactZeros.xlsx";
    % xxx = "<a href='file://localhost//Users/myself/Documents/ogr-external-projects/ecb-bear/BEAR-toolbox/tbx/gui_poc/tables/ExactZeros.xlsx'>Exact Zeros Table</a>";

    endPath = {"html", "identification", "settings.html"};
    sourcePath = fullfile(guiFolder, endPath{:});
    targetPath = fullfile(".", endPath{:});
    % TODO: $IDENTIFICATION_CONTENT --> $IDENTIFICATION_SELECTION_FORM
    gui.changeHtmlFile(sourcePath, targetPath, "$IDENTIFICATION_SETTING", xxx);

end%
