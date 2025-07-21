
function outputFile = populateNotes(topic)

    ftm = gui.FormToMatlab();

    notes = gui.readSettingsFile("notes");
    topicNotes = ftm.resolveSpecialCharacters(notes.(topic));
    area = gui.generateTextArea(topic, topicNotes, "gui_collectNotes");

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    if topic == "home"
        endPath = {"html", "notes.html"};
    else
        endPath = {"html", topic, "notes.html"};
    end
    inputFile = fullfile(guiFolder, endPath{:});
    outputFile = fullfile(".", endPath{:});

    gui.changeHtmlFile(inputFile, outputFile, "$NOTES", area);

end%

