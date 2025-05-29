function populateEstimatorSelection()
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);

    user_dir_settings = fullfile(pwd, 'settings');
    if ~exist(user_dir_settings, 'dir')
        mkdir(user_dir_settings);
    end
    copyfile(fullfile(gui_folder, "settings", "estimatorSettings.json"), fullfile(user_dir_settings, "estimatorSettings.json"));
    estimators = json.read(fullfile(user_dir_settings,"estimatorSettings.json"));
    
    input_file = fullfile(gui_folder, 'html', 'estimator_select.html');
    output_file = fullfile(pwd, 'html', 'estimator_select.html');
    gui.updateEstimatorSelectPage(input_file,output_file, estimators);
end