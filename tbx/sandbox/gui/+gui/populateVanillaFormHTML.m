
function populateVanillaFormHTML(formPath)

    arguments
        formPath (1, 2) cell
    end

    formPath = { string(formPath{1}), string(formPath{2}) };

    htmlEndPath = {"html", formPath{1}, formPath{2} + ".html"};
    action = "gui_collectVanillaForm " + formPath{1} + " " + formPath{2} + " ";

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, htmlEndPath{:});
    targetPath = fullfile(".", htmlEndPath{:});

    form = gui.readFormsFile(formPath);
    html = gui.generateFreeForm(form, action=action);
    gui.copyCustomHTML(sourcePath, targetPath, "?FORM?", html);

end%

