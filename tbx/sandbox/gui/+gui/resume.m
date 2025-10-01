
% Starting a GUI application

function resume()

    guiFolder = gui_getFolder();

    % Recreate HTML files from originals
    guiHTMLFolder = fullfile(guiFolder, "html");
    customHTMLFolder = fullfile(".", "html");
    if exist(customHTMLFolder, "dir")
        rmdir(customHTMLFolder, "s");
    end
    copyfile(guiHTMLFolder, customHTMLFolder);


    % Populate HTML files with current forms

    % Input data tab
    gui.populateDataSourceHTML();

    % Reduced-form estimation tab
    gui.populateEstimatorSelectionHTML();
    gui.populateEstimatorSettingsHTML();

    % Meta information tab
    gui.populateMetaSettingsHTML();

    % Dummy observations tab
    gui.populateDummiesSelectionHTML();

    % Structural identification tab
    gui.populateIdentificationSelectionHTML();
    gui.populateVanillaFormHTML({"identification", "cholesky"});

    % Tasks to execute tab
    gui.populateTasksSelectionHTML();
    gui.populateVanillaFormHTML({"tasks", "prerequisites"});
    gui.populateVanillaFormHTML({"tasks", "unconditional"});
    gui.populateVanillaFormHTML({"tasks", "conditional"});

    % Matlab script tab
    gui.populateScriptSettingsHTML();
    gui.populateScriptExecutionHTML();
    gui.populateScriptListingHTML();

    % Populate notes in all tabs
    tabs = [
        "home", "data", "meta", "estimation", ...
        "identification", "tasks", "script"
    ];
    for i = tabs
        gui.populateNotesHTML(i);
    end


    % Resolve table file paths
    guiFolder = gui_getFolder();
    currentFolder = pwd();
    mapping = {
        fullfile("identification", "zeros.html"), "ExactZeros.xlsx"
        fullfile("identification", "inequality.html"), "InequalityRestrictions.xlsx"
    };
    for i = 1 : height(mapping)
        htmlPath = mapping{i, 1};
        tableName = mapping{i, 2};
        sourcePath = fullfile(guiFolder, "html", htmlPath);
        targetPath = fullfile(".", "html", htmlPath);
        gui.copyCustomHTML(sourcePath, targetPath, "{PATH}", fullfile(currentFolder, "tables", tableName));
    end

    % Open Matlab web browser with the landing page
    customHTMLFolder = fullfile(".", "html");
    indexPath = fullfile(customHTMLFolder, 'index.html');
    web(indexPath);

end%

