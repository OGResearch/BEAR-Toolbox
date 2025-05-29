function metaSettings = populateMeta()
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);
    Meta = json.read(fullfile(gui_folder,"settings","metaSettings.json"));

    metaList = gui.createForm(Meta,"Meta Settings");
    gui.changeHtmlFile(fullfile(gui_folder, 'html', 'meta.html'), "$Meta_settings", metaList);
    metaSettings = Meta;
end