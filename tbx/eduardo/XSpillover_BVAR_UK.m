clear
close all
rehash path

addpath ../sandbox
%%
addpath ../bear
%%
percentiles = [10, 50, 90];
prctileFunc = @(x) prctile(x, percentiles, 2);
firstFunc = @(x) x(:, 1, :, :, :);
medianFunc = @(x) median(x, 2);
flatFunc = @(x) x(:, :);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];
defaultColors = get(0, "defaultAxesColorOrder");

configStruct = json.read("testConfig_UK.json");
config = bear6.Config(configStruct);

config;
%%
inputTbx = tablex.fromCsv("exampleData_repl_uk.csv");
%%
meta = model.Meta( ...
    endogenous=config.Meta_EndogenousConcepts, ...
    units=config.Meta_Units, ...
    exogenous=config.Meta_ExogenousNames, ...
    order=config.Meta_Order, ...
    intercept=config.Meta_HasIntercept, ...
    estimationSpan=config.Meta_EstimationSpan, ...
    ...
    identificationHorizon=10, ... config.Meta_IdentificationHorizon, ...
    shockConcepts=config.Meta_ShockConcepts ...
);
meta;

dataH = model.DataHolder(meta, inputTbx);
dataH;

estimatorR = estimator.Minnesota( ...
    meta, ...
    config.Estimator_Settings{:} ...
);
estimatorR;
%%
minnesotaD = dummies.Minnesota(exogenousLambda=100,lambda = 0.16,lagDecay=1, exogenous=true, autoregression = 0.3);
initialD = dummies.InitialObservations(lambda = 0.001);
longrunD = dummies.LongRun(lambda=1);
sumcoefD = dummies.SumCoefficients(lambda=0.1);

%%
modelR = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
    , dummies={minnesotaD, initialD, sumcoefD} ...
    , stabilityThreshold=Inf ...
);

modelR.initialize();
modelR.presample(2);
res = modelR.estimateResiduals();


%%
% modelR.presample(2);
% modelR

id = identifier.Cholesky();
modelS = model.Structural(reducedForm=modelR, identifier=id);
modelS.initialize();
modelS.presample(2);

a = modelS.simulateResponses();
b = modelS.calculateFEVD(includeInitial=false);
c = modelS.estimateShocks();


%%

%{
residTbx = modelR.estimateResiduals();
fcastStart = datex.shift(modelR.Meta.EstimationEnd, +1);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, +14);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastStart, fcastEnd
fcastTbx = modelR.forecast(fcastSpan);
fcastTbx

fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
fcastPrctileTbx

tablex.plot( ...
    fcastPrctileTbx, "Y_UK", ...
    plotSettings={"color", defaultColors(1, :), {"lineStyle"}, {":"; "-"; ":"}} ...
);
%}

%%
%Instant zeros
exactZerosTbx = tablex.forExactZeros(modelR);

%Domestic demand
exactZerosTbx{"Y", "DD"} = 0;
exactZerosTbx{"P", "DD"} = 0;
exactZerosTbx{"I", "DD"} = 0;
exactZerosTbx{"OIL", "DD"} = 0;
%Domestic supply
exactZerosTbx{"Y", "DS"} = 0;
exactZerosTbx{"P", "DS"} = 0;
exactZerosTbx{"I", "DS"} = 0;
exactZerosTbx{"OIL", "DS"} = 0;
%Domestic MP
exactZerosTbx{"Y", "DMP"} = 0;
exactZerosTbx{"P", "DMP"} = 0;
exactZerosTbx{"I", "DMP"} = 0;
exactZerosTbx{"OIL", "DMP"} = 0;
%Unidentified
exactZerosTbx{"Y", "UD"} = 0;
exactZerosTbx{"P", "UD"} = 0;
exactZerosTbx{"I", "UD"} = 0;
exactZerosTbx{"OIL", "UD"} = 0;

exactZerosTbx

identExactZeros = identifier.ExactZeros(exactZerosTbx);
identExactZeros

%%
rng(0);

testStrings = [
    %Domestic demand
    "$SHKRESP(1, 'Y_UK', 'DD') > 0"
    "$SHKRESP(1, 'P_UK', 'DD') > 0"
    "$SHKRESP(1, 'I_UK', 'DD') > 0"
    %Domestic supply
    "$SHKRESP(1, 'Y_UK', 'DS') < 0"
    "$SHKRESP(1, 'P_UK', 'DS') > 0"
    %Dom MP
    "$SHKRESP(1, 'Y_UK', 'DMP') < 0"
    "$SHKRESP(1, 'P_UK', 'DMP') < 0"
    "$SHKRESP(1, 'I_UK', 'DMP') > 0"
    %Foreign demand
    "$SHKRESP(1, 'Y', 'FD') > 0"
    "$SHKRESP(1, 'P', 'FD') > 0"
    "$SHKRESP(1, 'I', 'FD') > 0"
    "$SHKRESP(1, 'OIL', 'FD') > 0"
    %Foreign supply
    "$SHKRESP(1, 'Y', 'FS') < 0"
    "$SHKRESP(1, 'P', 'FS') > 0"
    "$SHKRESP(1, 'OIL', 'FS') < 0"
    %Foreign MP
    "$SHKRESP(1, 'Y', 'FMP') < 0"
    "$SHKRESP(1, 'P', 'FMP') < 0"
    "$SHKRESP(1, 'I', 'FMP') > 0"
    %Oil
    "$SHKRESP(1, 'OIL', 'OILS') > 0"
    "$SHKRESP(1, 'Y', 'OILS') < 0"
    "$SHKRESP(1, 'P', 'OILS') > 0"

    % "$FEVD(2, 'Y_UK', 'DD') / sum($FEVD(2, 'Y_UK', :)) > 0.1"
    % "$SHKEST('1997-Q4', 'DD') > 0.2"
    % "$SHKCONT('1997-Q4', 'Y_UK', 'DD') > 0.3"
];

testStrings


id2 = identifier.Verifiables( ...
    testStrings, ...
    exactZeros=identExactZeros, ...
    shortCircuit=false, ...
    maxCandidates=Inf ...
);
id2

modelS = model.Structural( ...
    reducedForm=modelR, ...
    identifier=id2 ...
);

% vp = identifier.VerifiableProperties(modelS);
% vt = identifier.VerifiableTests(testStrings(1:end));
% 
% [func, occurrence, funcString] = vt.buildTestEnvironment(modelS.Meta);


%%

% five = load("xxx.mat");
% 
% presampled = cell(1, 10);
% for i = 1 : 10
%     sample = struct();
%     sample.beta = five.beta_gibbs(:, i);
%     sample.sigma = reshape(five.sigma_gibbs(:, i), 8, 8);
%     % sample.D = transpose(reshape(five.D_record(:, i), 8, 8));
%     presampled{i} = sample;
% end

% modelS.ReducedForm.Presampled = presampled;

modelS.initialize();

rng(0);

info = modelS.presample(10);
modelS.CandidateCounter

shks = modelS.estimateShocks();
resp = modelS.simulateResponses();
fevd = modelS.calculateFEVD(includeInitial=false);
cont = modelS.calculateContributions();

