function populateMeta()
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);

    user_dir_settings = fullfile(pwd, 'settings');
    if ~exist(user_dir_settings, 'dir')
        mkdir(user_dir_settings);
    end
    copyfile(fullfile(gui_folder, "settings", "metaSettings.json"), fullfile(user_dir_settings, "metaSettings.json"));
    meta = json.read(fullfile(user_dir_settings,"metaSettings.json"));
    
    input_file = fullfile(gui_folder, 'html', 'meta.html');
    output_file = fullfile(pwd, 'html', 'meta.html');
    gui.updateMetaPage(input_file,output_file, meta);
end