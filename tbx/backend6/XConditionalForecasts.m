%% Conditional forecasts 
%
% * Prepare a reduced-form model for experiments with zero restrictions
% * Prepare a table with conditions
% * Prepare a table with a "simulation plan"
% * Run and report a conditional report using all shocks vs seletected shocks


clear
close all
rehash path

addpath ../sandbox
addpath ../bear


%% Define convenience functions 
%
% The |extremesFunc| function compresses any number of samples (draws from the
% posterior) into two numbers - the minimum and the maximum.


percentiles = [10, 50, 90];
prctilesFunc = @(x) prctile(x, percentiles, 2);
medianFunc = @(x) median(x, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

defaultColors = get(0, "defaultAxesColorOrder");


%% Prepare data and a reduced-form model 
%
% * Same as in introCommonTasks

inputTbl = tablex.fromCsv("exampleData.csv");

inputTbl = tablex.extend(inputTbl, -Inf, datex.q(2017,4));
inputTbl.Oil = fillmissing(inputTbl.Oil, "nearest");


estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = model.Meta( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"], ...
    units="", ...
    exogenous="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = model.DataHolder(meta, inputTbl);

estimatorR = estimator.NormalWishart(meta);

modelR = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
    , stabilityThreshold=Inf ...
);


%% Identify a SVAR using Cholesky with reordering 
%
% * Use Cholesky as if the endogenous variables were ordered in a different
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can
% omit that part


identChol = identifier.Cholesky(order=["DOM_CPI", "DOM_GDP", "STN"]);

% Equivalent to
% identChol = identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = model.Structural(reducedForm=modelR, identifier=identChol);

modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D

respTbl0 = modelS0.simulateResponses();
respTbl0 = tablex.apply(respTbl0, extremesFunc);
respTbl0 = tablex.flatten(respTbl0);

respTbl0


%% Create forecast assumptions 

fcastStart = datex.shift(estimEnd, 1);
fcastEnd = datex.shift(estimEnd, 12);
fcastSpan = datex.span(fcastStart, fcastEnd);
initStart = datex.shift(fcastStart, -modelS0.Meta.Order);

[dataTbl, planTbl] = tablex.forConditional(modelS0, fcastSpan);
dataTbl
planTbl

dataTbl{datex("2015-Q4"), "DOM_GDP"} = -1.5;
dataTbl{datex("2016-Q4"), "DOM_CPI"} = 5.5;
%dataTbl{datex("2016-Q3"), "STN"} = 5.5;

dataTbl{:, "Oil"} = inputTbl{end, "Oil"};


%% Run across-the-board vs selective conditions forecasts 
%

planTbl{datex("2015-Q4"), "DOM_GDP"} = "DEM POL";
planTbl{datex("2016-Q4"), "DOM_CPI"} = "DEM SUP";
%planTbl{datex("2016-Q3"), "DOM_CPI"} = "SUP";


% Calculate contributions of shocks, exogenous and initials on the estimation
% span
histContTbl = modelS0.calculateContributions();


% Run unconditional forecast and calculate contributions starting at the
% beginning of the forecast
[fcastTbl1, fcastContTbl1] = modelS0.forecast( ...
    fcastSpan, ...
    contributions=true ...
);


% Run unconditional forecast and calculate contributions starting at the
% beginning of the estimation span
[fcastTbl2, fcastContTbl2] = modelS0.forecast( ...
    fcastSpan, ...
    contributions=true, ...
    precontributions=histContTbl ...
);


% Run unconditional forecast and calculate contributions starting at the
% beginning of the estimation span
[condTbl1, condContTbl1] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=dataTbl, ...
    plan=[], ...
    contributions=true ...
);

[condTbl2, condContTbl2] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=dataTbl, ...
    plan=[], ...
    contributions=true, ...
    precontributions=histContTbl ...
);

condPrctilesTbl1 = tablex.apply(condTbl1, prctilesFunc);
condPrctilesTbl2 = tablex.apply(condTbl2, prctilesFunc);

return


%% Visualize conditional forecasts 
%

plotSettings = { ...
   {"color"}, {defaultColors(2,:); defaultColors(1,:); defaultColors(2,:)},  ...
   {"lineStyle"}, {":";"-";":"}, ...
};

ch = visual.Chartpack( ...
    span=datex.span(initStart, fcastEnd), ...
    namesToPlot=[modelS0.Meta.EndogenousNames, modelS0.Meta.ShockNames], ...
    plotSettings=plotSettings ...
);

ch.Captions = "Across-the-board conditional forecast";
ch.plot(condPrctilesTbl1);

ch.Captions = "Selective conditional forecast";
ch.plot(condPrctilesTbl2);


%% Visualize contributions 


