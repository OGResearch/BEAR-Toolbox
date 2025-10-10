
function code = codePreamble()

    mts = gui.MatlabToScript();
    timestamp = datetime();
    settings = gui.getCurrentPrerequisites();
    module = gui.getCurrentModule();

    place = struct();
    place.TIMESTAMP = string(timestamp);
    place.MODULE = string(module);
    place.PERCENTILES = mts.numbers(settings.Percentiles.value);
    place.OUTPUT_FOLDER = mts.string(settings.OutputFolder.value);
    place = setupPrintFunctions_(place, settings);

    code = script.readTemplate("preamble");
    code = script.replaceInCode(code, place);

end%


function place = setupPrintFunctions_(place, settings)
    %[
    printFunction = "@display; % @(x) []";
    silentFunction = "@(x) []; % @display";
    %
    if settings.PrintInfo.value
        place.PRINT_INFO = printFunction;
    else
        place.PRINT_INFO = silentFunction;
    end
    %
    if settings.PrintTables.value
        place.PRINT_TABLE = printFunction;
    else
        place.PRINT_TABLE = silentFunction;
    end
    %
    if settings.PrintObjects.value
        place.PRINT_OBJECT = printFunction;
    else
        place.PRINT_OBJECT = silentFunction;
    end
    %]
end%

