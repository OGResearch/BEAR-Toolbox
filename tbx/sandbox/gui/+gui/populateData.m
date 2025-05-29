function populateData()
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);

    user_dir_settings = fullfile(pwd, 'settings');
    if ~exist(user_dir_settings, 'dir')
        mkdir(user_dir_settings);
    end
    copyfile(fullfile(gui_folder, "settings", "dataSettings.json"), fullfile(user_dir_settings, "dataSettings.json"));
    data = json.read(fullfile(user_dir_settings,"dataSettings.json"));
    
    input_file = fullfile(gui_folder, 'html', 'data.html');
    output_file = fullfile(pwd, 'html', 'data.html');
    gui.updateDataPage(input_file,output_file, data);
end