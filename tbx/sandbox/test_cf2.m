
meta = modelS.Meta;

%Setting up forecast range
shortForecastSpan = datex.span("2012-Q1", "2014-Q4");
longForecastSpan = datex.longSpanFromShortSpan(shortForecastSpan, meta.Order);
longYXZ = modelR.getSomeYXZ(longForecastSpan); %for simplicity here I take conditions from realization
forecastStartIndex = datex.diff(shortForecastSpan(1), meta.ShortStart) + 1;
forecastHorizon = numel(shortForecastSpan);

%Setting-up conditions
variableNames = modelS.Meta.EndogenousNames;
numVariables = numel(variableNames);
init = repmat({cell(forecastHorizon, 1)}, 1, numVariables);
condTable = timetable( ...
    init{:}, ...
    rowTimes=shortForecastSpan, ...
    variableNames=variableNames ...
    );
condTable{datex.span("2012-Q1", "2013-Q1"), "DOM_GDP"} = {["DEM"]};
condTable{datex.span("2014-Q1", "2014-Q4"), "DOM_CPI"} = {["SUP"]};

%create CF arrays
cfconds = createCfcond(meta, longYXZ, condTable, shortForecastSpan); 
cfshocks = createCfshocks(meta, condTable, shortForecastSpan);
cfblocks = createCfblocks(cfconds, cfshocks);
return

%Setting up options
options.hasIntercept = meta.HasIntercept;
options.order = meta.Order;
options.cfconds = cfconds;
options.cfblocks = cfblocks;
options.cfshocks = cfshocks;

sample = modelS.Presampled{1};
draw = modelS.Estimator.ConditionalDrawer(sample, forecastStartIndex, forecastHorizon);
D = sample.D;
beta_iter = [draw.beta{:}];
[cdforecast2] = cforecast4S(D, beta_iter, longYXZ, forecastHorizon, options);
