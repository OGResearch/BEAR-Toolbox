% Starting a GUI application
function start()
    htmlDir = gui.populateHTML();
    gui.populateMeta();
    gui.populateData();
    gui.populateEstimatorSelection();
    gui.populateIdentification();

    indexPath = fullfile(htmlDir, 'index.html');
    % Open system web browser
    web(indexPath);
    
end
