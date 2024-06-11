
function plotHandle = plot(table, names, options)

    arguments
        table timetable
        names (1, :) string

        options.Periods = Inf
        options.Axes = []
        options.Variant = ":"
        options.PlotSettings (1, :) cell = {}
    end

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    periods = options.Periods;
    if isequal(periods, Inf)
        periods = tablex.span(table);
    end

    ax = {};
    if ~isempty(options.Axes)
        ax = {options.Axes};
    end

    dataCell = tablex.retrieveDataAsCellArray(table, names, periods, variant=options.Variant);
    plotHandle = plot(ax{:}, periods, [dataCell{:}], options.PlotSettings{:});

end%
