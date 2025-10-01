
function targetPath = populateDataSourceHTML()

    dataSource = gui.readSettingsFile("dataSource");
    form = gui.generateFreeForm(dataSource, action="gui_collectDataSource");

    guiFolder = fileparts(gui.getDirectory("gui.Tracer"));
    endPath = {"html", "data", "source.html"};
    sourcePath = fullfile(guiFolder, endPath{:});
    targetPath = fullfile(".", endPath{:});

    dataSourceFile = dataSource.FileName.value;
    if isempty(dataSourceFile) || isequal(dataSourceFile, "")
        dataSourceFile = "[No data file selected]";
    end

    gui.changeHtmlFile( ...
        sourcePath, targetPath ...
        , "$DATA_SOURCE_FORM", form ...
        , "$DATA_SOURCE_FILE", dataSourceFile ...
    );

end%

