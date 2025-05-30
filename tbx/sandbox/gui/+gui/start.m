
% Starting a GUI application

function start()

    gui.createUserFolders();

    gui.populateMetaHTML();
    gui.populateDataHTML();
    gui.populateEstimatorSelectionHTML();
    gui.populateIdentificationSelectionHTML();

    % Open Matlab web browser
    userHTMLFolder = fullfile(".", "html");
    indexPath = fullfile(userHTMLFolder, 'index.html');
    web(indexPath);

end%
