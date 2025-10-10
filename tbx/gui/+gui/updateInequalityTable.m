
function updateInequalityTable(meta)

    INEQUALITY_XLSX = "InequalityRestrictions.xlsx";
    TITLE = "Inequality (sign) restrictions";

    endogenousNames = meta.getSeparableEndogenousNames();
    shockNames = meta.getSeparableShockNames();

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=INEQUALITY_XLSX, ...
        title=TITLE ...
    );

end%

