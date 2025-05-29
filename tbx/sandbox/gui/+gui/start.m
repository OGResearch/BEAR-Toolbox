% Starting a GUI application
function start()
    htmlDir = gui.populateHTML();
    gui.populateMeta();

    indexPath = fullfile(htmlDir, 'index.html');
    % Open system web browser
    web(indexPath);
    
end
