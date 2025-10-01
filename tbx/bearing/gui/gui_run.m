
function gui_run()

    disp("Loading input data");

    inputDataFileSelection = gui.querySelection("InputDataFile");
    disp("Input data file: " + inputDataFileSelection);

    disp("Estimating the model");

    estimatorSelection = gui.querySelection("Estimator");
    disp("Estimator: " + estimatorSelection);

    estimatorSettingsPath = fullfile(".", "settings", "estimatorSettings.json");
    estimatorSettings = jsondecode(fileread(estimatorSettingsPath));
    settings = struct();
    if estimatorSelection ~= ""
        settings = estimatorSettings.(estimatorSelection);
    end
    disp("Estimator settings");
    disp(settings);

    identificationSelection = gui.querySelection("Identification");
    disp("Identification: " + identificationSelection);

    disp("Running the tasks");

end%

