%% Panel models

clear
close all
rehash path

addpath ../sandbox
addpath ../bear


%% Prepare data and a reduced-form model

inputTbx = tablex.fromCsv("panel_data.csv");

estimStart = datex.q(1972,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = model.Meta( ...
    endogenous=["YER", "HICSA", "STN"], ...
    units=["US", "EA", "UK"], ...
    exogenous=["Oil"], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = model.DataHolder(meta, inputTbx);


%% Mean OLS and Normal Wishart Models

numSamples = 10;

estimatorR1 = estimator.MeanOLSPanel(meta);
estimatorR1.Settings


estimatorR2 = estimator.NormalWishartPanel(meta);

modelR1 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR1 ...
    , stabilityThreshold=Inf ...
);

modelR2 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR2 ...
    , stabilityThreshold=Inf ...
);

rng(0)
modelR1.initialize();
info1 = modelR1.presample(numSamples);
% disp('Beta Median OLS Model:')
% betaMedian1 = calcMedian(modelR1,"beta");

rng(0)
modelR2.initialize();
info2 = modelR2.presample(numSamples);
% disp('Beta Median Normal Wishart Model:')
% betaMedian2 = calcMedian(modelR2,"beta");



%% Random Effect Models

estimatorR3 = estimator.ZellnerHongPanel(meta);
estimatorR3.Settings

estimatorR4 = estimator.HierarchicalPanel(meta);
estimatorR4.Settings

modelR3 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR3 ...
    , stabilityThreshold=Inf ...
);

modelR4 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR4 ...
    , stabilityThreshold=Inf ...
);

rng(0)
modelR3.initialize();
info3 = modelR3.presample(numSamples);
% disp('Beta Median Zellner Hong Model:')
% betaMedian3 = calcMedian(modelR3,"beta")

rng(0)
modelR4.initialize();
info4 = modelR4.presample(numSamples);
% disp('Beta Median Hierarchical Model:')
% betaMedian4 = calcMedian(modelR4,"beta")


%% Estimate residuals

resid1 = modelR1.estimateResiduals();
resid2 = modelR2.estimateResiduals();
resid3 = modelR3.estimateResiduals();
resid4 = modelR4.estimateResiduals();


%% Run unconditional forecast

fcastStart = datex.shift(estimEnd, -9);
fcastEnd = datex.shift(estimEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcast1 = modelR1.forecast(fcastSpan);
fcast2 = modelR2.forecast(fcastSpan);
fcast3 = modelR3.forecast(fcastSpan);
fcast4 = modelR4.forecast(fcastSpan);


%% Indentify a SVAR using Cholesky (without reordering)
% 

identChol = identifier.Cholesky(order=["HICSA", "STN"]);

modelS1 = model.Structural(reducedForm=modelR1, identifier=identChol);
modelS1.initialize();
info1 = modelS1.presample(numSamples);

modelS2 = model.Structural(reducedForm=modelR2, identifier=identChol);
modelS2.initialize();
info2 = modelS2.presample(numSamples);

modelS3 = model.Structural(reducedForm=modelR3, identifier=identChol);
modelS3.initialize();
info3 = modelS3.presample(numSamples);

modelS4 = model.Structural(reducedForm=modelR4, identifier=identChol);
modelS4.initialize();
info4 = modelS4.presample(numSamples);


%% Simulate shock responses

resp1 = modelS1.simulateResponses();
resp2 = modelS2.simulateResponses();
resp3 = modelS3.simulateResponses();
resp4 = modelS4.simulateResponses();


%% Calcuate FEVD

fevd1 = modelS1.calculateFEVD();
fevd2 = modelS2.calculateFEVD();
fevd3 = modelS3.calculateFEVD();
fevd4 = modelS4.calculateFEVD();