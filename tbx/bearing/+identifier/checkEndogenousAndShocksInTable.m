
function checkEndogenousAndShocksInTable(tbl, meta)

    arguments
        tbl (:, :) table
        meta (1, 1) model.Meta
    end

    compareLists = @isequal;

    tableEndogenousHeadings = textual.stringify(tbl.Properties.RowNames);
    if ~compareLists(meta.getSeparableEndogenousNames(), tableEndogenousHeadings)
        error("Row names in the restriction table must match endogenous names in the model.");
    end

    tableShockHeadings = textual.stringify(tbl.Properties.VariableNames);
    if ~compareLists(meta.getSeparableShockNames(), tableShockHeadings)
        error("Column names in the restriction table must match shock names in the model.");
    end

end%

