
function code = codePreamble(options)

    arguments
        options.Prerequisites (1, 1) struct
    end

    mts = gui.MatlabToScript();
    timestamp = datetime();

    place = struct();
    place.TIMESTAMP = string(timestamp);
    place.PERCENTILES = mts.numbers(options.Prerequisites.Percentiles.value);

    place = setupPrintFunctions_(place);

    code = script.readTemplate("preamble");
    code = script.replaceInCode(code, place);

end%


function place = setupPrintFunctions_(place)
    %[
    scriptSettings = gui.getCurrentScriptSettings();
    printFunction = "@(x) disp(x)";
    silentFunction = "@(x) []";
    %
    if scriptSettings.PrintTables
        place.PRINT_TABLE = printFunction;
    else
        place.PRINT_TABLE = silentFunction;
    end
    %
    if scriptSettings.PrintObjects
        place.PRINT_OBJECT = printFunction;
    else
        place.PRINT_OBJECT = silentFunction;
    end
    %]
end%

