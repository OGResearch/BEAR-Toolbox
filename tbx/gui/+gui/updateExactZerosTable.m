
function updateExactZerosTable(meta)

    EXACT_ZEROS_XLSX = "ExactZeros.xlsx";
    TITLE = "Instant exact zero restrictions";

    endogenousNames = meta.getSeparableEndogenousNames();
    shockNames = meta.getSeparableShockNames();

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=EXACT_ZEROS_XLSX, ...
        title=TITLE ...
    );

end%

