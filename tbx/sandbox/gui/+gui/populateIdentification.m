function populateIdentification()
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);

    user_dir_settings = fullfile(pwd, 'settings');
    if ~exist(user_dir_settings, 'dir')
        mkdir(user_dir_settings);
    end
    % copyfile(fullfile(gui_folder, "settings", "estimatorSettings.json"), fullfile(user_dir_settings, "estimatorSettings.json"));
    % estimators = json.read(fullfile(user_dir_settings,"estimatorSettings.json"));
    identifications = struct();
    identifications.Cholesky = struct();
    identifications.ExactZero = struct();
    
    input_file = fullfile(gui_folder, 'html', 'identifications.html');
    output_file = fullfile(pwd, 'html', 'identifications.html');
    gui.updateIdentificationPage(input_file,output_file, identifications);
end