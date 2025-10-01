
function plotHandles = plot(table, names, options)

    arguments
        table timetable
        names (1, :) string
        %
        options.Periods = Inf
        options.Axes = []
        options.Variant = ':'
        options.Dims (1, :) cell = cell.empty(1, 0)
        options.PlotSettings (1, :) cell = {}
        options.PlotFunc = @plot
        options.BarStyle (1, 1) string = "stacked"
    end

    if ischar(options.PlotFunc) || isstring(options.PlotFunc)
        options.PlotFunc = str2func(options.PlotFunc);
    end

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    periods = options.Periods;
    if isequal(periods, Inf)
        periods = tablex.span(table);
    end

    if ~isempty(options.Axes)
        ax = options.Axes;
    else
        ax = gca();
    end

    dataCell = tablex.retrieveDataAsCellArray( ...
        table, names, periods, ...
        variant=options.Variant, ...
        dims=options.Dims ...
    );

    barStyle = {};
    if isequal(func2str(options.PlotFunc), 'bar')
        barStyle = {options.BarStyle};
    end

    plotHandles = options.PlotFunc( ...
        ax, periods, [dataCell{:}(:,:)], barStyle{:} ...
    );

    if ~isempty(options.PlotSettings)
        set(plotHandles, options.PlotSettings{:});
    end

end%

