% Starting a GUI application
function start()
    htmlDir = gui.populateHTML();
    metaSettings = gui.populateMeta();

    indexPath = fullfile(htmlDir, 'index.html');
    % Open system web browser
    web(indexPath);
    
    setappdata(0, 'metaSettings', metaSettings);
end
