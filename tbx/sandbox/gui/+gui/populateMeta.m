function metaSettings = populateMeta()
    gui_folder = gui.getDirectory("gui.Tracer");
    modelS = json.read(fullfile(gui_folder,"settings","modelSettings.json"));

    metaList = gui.createForm(modelS.Meta,"Meta Settings");
    gui.changeHtmlFile(fullfile(gui_folder, 'html', 'meta.html'), "$Meta_settings", metaList);
    metaSettings = modelS.Meta;
end