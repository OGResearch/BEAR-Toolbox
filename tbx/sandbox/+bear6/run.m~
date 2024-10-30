
function master = run(getConfigOptions)

    arguments
        getConfigOptions.ConfigFile
        getConfigOptions.ConfigStruct
    end

    cellArgs = namedargs2cell(getConfigOptions);
    configStruct = bear6.getConfigStruct(cellArgs{:});
    master = bear6.Master(configStruct);
    master.readInputData();
    master.setDates();
    master.createReducedForm();

end%

