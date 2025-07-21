
% Starting a GUI application

function resume()

    gui.populateDataSourceHTML();
    gui.populateMetaHTML();
    gui.populateEstimatorSelectionHTML();
    gui.populateEstimatorSettingsHTML();
    gui.populateIdentificationSelectionHTML();
    gui.populateTaskSelectionHTML();

    gui.populateNotes("home");
    gui.populateNotes("data");
    gui.populateNotes("meta");
    gui.populateNotes("estimation");
    gui.populateNotes("identification");
    gui.populateNotes("tasks");

    % Open Matlab web browser
    userHTMLFolder = fullfile(".", "html");
    indexPath = fullfile(userHTMLFolder, 'index.html');
    web(indexPath);

end%
