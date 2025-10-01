
function code = codeReducedFormModel(options)

    arguments
        options.Module (1, 1) string
        options.MetaSettings (1, 1) struct
        options.DataSource (1, 1) struct
        options.Estimator (1, 1) string
        options.EstimatorSettings (1, 1) struct
    end

    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place.MODULE = string(options.Module);
    place.ESTIMATOR = string(options.Estimator);

    % Settings as code
    place.META_SETTINGS = script.printFormAsSettings(options.MetaSettings);
    place.INPUT_DATA_PATH = mts.string(options.DataSource.FilePath.value);
    place.ESTIMATOR_SETTINGS = script.printFormAsSettings(options.EstimatorSettings);

    code = script.readTemplate("reducedFormModel");
    code = script.replaceInCode(code, place);

end%

