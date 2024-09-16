
function dataTable = readInputData(config)

    INPUT_DATA_READER = struct( ...
        "csv", @tablex.fromCsv ...
    );

    dataTable = [];

    if isfield(config, "data") && ~isempty(config.data)
        data = config.data;
        reader = INPUT_DATA_READER.(lower(data.format));
        dataTable = reader(data.source);
        return
    end

end%

