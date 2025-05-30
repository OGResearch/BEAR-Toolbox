
function targetPath = populateIdentificationSettingsHTML()

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));

    % form = ...

    sourcePath = fullfile(guiFolder, "html", "identification_settings.html");
    targetPath = fullfile(".", "html", "identification_settings.html");
    % TODO: $IDENTIFICATION_CONTENT --> $IDENTIFICATION_SELECTION_FORM
    % gui.changeHtmlFile(sourcePath, targetPath, "$IDENTIFICATION_CONTENT", form);

end%
