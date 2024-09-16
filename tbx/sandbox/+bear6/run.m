
function master = run(getConfigOptions)

    arguments
        getConfigOptions.ConfigFile
        getConfigOptions.ConfigStruct
    end

    configStruct = bear6.getConfigStruct(namedargs2cell(getConfigOptions);
    master = bear6.Master(configStruct);
    master.readInputData();
    master.setDates();
    master.createReducedForm();

end%

