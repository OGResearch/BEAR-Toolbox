
function dataFilePath = getCurrentDataFilePath()

    dataSource = gui.getCurrentDataSource();
    dataFilePath = string(dataSource.FilePath.value);

    if ~isscalar(dataFilePath)
        dataFilePath = "";
        return
    end

    if ismissing(dataFilePath)
        dataFilePath = "";
        return
    end

end%

