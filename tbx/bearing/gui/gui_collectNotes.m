
function gui_collectNotes(submission)

    ftm = gui.FormToMatlab();

    submission = gui.resolveRawFormSubmission(submission);
    notes = gui.readSettingsFile("notes");
    topic = textual.fields(submission);
    notes.(topic) = submission.(topic);
    gui.writeSettingsFile(notes, "notes");

    thisFilePath = gui.populateNotes(topic);
    web(thisFilePath);

end%

