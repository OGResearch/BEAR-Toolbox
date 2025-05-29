function collectMetaData(varargin)

    % Extract varargin if provided
    if nargin > 0
        url = varargin{1};
    else
        url = '';
    end

    user_dir_settings = fullfile(pwd, 'settings');
    gui_folder = gui.getDirectory("gui.Tracer");
    gui_folder = fileparts(gui_folder);

    % read current metadata
    meta = json.read(fullfile(user_dir_settings,"metaSettings.json"));
    
    % userData = gui.parseFromUrl(url);
    % userData is a struct with keys and values from the URL query string
    
    % data cleanup
    userData = gui.resolveFormSubmission(url, meta);

    % update metadata with userData
    meta = gui.updateData(meta, userData);

    % save updated metadata to file
    jsonFilePath = fullfile(user_dir_settings, 'metaSettings.json');
    json.write(meta,jsonFilePath);
    
    % regenerate Meta page
    gui.updateMetaPage(...
        fullfile(gui_folder, 'html', 'meta.html'), ...
        fullfile(pwd, 'html', 'meta.html'), ...
        meta);
end
