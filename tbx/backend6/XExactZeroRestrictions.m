%% Exact zero restrictions 

% * Prepare a reduced-form model for experiments with zero restrictions
% * Identify a SVAR using Cholesky with reordering
% * Identify a SVAR based on exact zero restrictions only
% * Combine exact zero restrictions with general restrictions
% * Use tables to specify sign restrictions


clear
close all
rehash path

addpath ../sandbox
addpath ../sandbox/gui
addpath ../bear


%% Convenience functions 

% The `extremesFunc` function compresses any number of samples (draws from the
% posterior) into two numbers - the minimum and the maximum.

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];


%% Prepare data and a reduced-form model 

% * Same as in `introCommonTasks`

inputTbl = tablex.fromCsv("exampleData.csv");

estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = base.Meta( ...
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

dataH = base.DataHolder(meta, inputTbl);


estimatorR = base.estimator.NormalWishart( ...
    meta ...
    , stabilityThreshold=Inf ...
);


modelR = base.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
);



%% Indentify a SVAR using Cholesky with reordering 

% * Use Cholesky as if the endogenous variables were ordered in a different
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can
% omit that part

identChol = base.identifier.Cholesky(order=["DOM_CPI", "DOM_GDP", "STN"]);

% Equivalent to
% identChol = base.identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = base.Structural(reducedForm=modelR, identifier=identChol);

modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D

respTbl0 = modelS0.simulateResponses();
respTbl0 = tablex.apply(respTbl0, extremesFunc);
respTbl0 = tablex.flatten(respTbl0);

respTbl0

contribsTbl0 = modelS0.calculateContributions();


%% Specify exact zero restrictions 

% * Create an empty table for exact zero restrictions using `tablex.forExactZeros`
% * The table has endogenous variables in rows, shocks in columns
% * Fill in zeros for the elements to be restricted
% * The algorithm can only handle *underdetermined* systems, meaning it must
% have at least one "degree of freedom"; this means the max number of zero restrictions
% is   `n * (n-1) / 2 - 1`
% * The algorithm is able handle an edge case of no restrictions - it simply
% produces fully randomized unconstrained factors of the covariance matrix

exactZerosTbl0 = tablex.forExactZeros(modelR);
exactZerosTbl0{"DOM_CPI", "DEM"} = 0;
exactZerosTbl0{"STN", "SUP"} = 0;
exactZerosTbl0

tablex.writetable(exactZerosTbl0, "exactZerosTbl.xlsx");
exactZerosTbl = tablex.readtable("exactZerosTbl.xlsx", conversion=@double);


%% Identify a SVAR using exact zero restrictions 

% * Create an "exact zero" identifier from the exact zeros table
% * Use this identifier to set up a SVAR object
% * Initialize and presample...


identExactZeros = base.identifier.ExactZeros(exactZerosTbl);

identExactZeros

modelS1 = base.Structural(reducedForm=modelR, identifier=identExactZeros);

modelS1

modelS1.initialize();
info1 = modelS1.presample(100);

respTbl1 = modelS1.simulateResponses();
respTbl1 = tablex.apply(respTbl1, extremesFunc);
respTbl1 = tablex.flatten(respTbl1);

respTbl1


%% Identify a SVAR using sign restrictions 

rng(0);

signStrings = [
    "$SHKRESP(2, 'DOM_GDP', 'DEM') > 0"
    "$SHKRESP(2, 'DOM_CPI', 'DEM') > 0"

    "$SHKRESP(3, 'DOM_GDP', 'DEM') > 0"
    "$SHKRESP(3, 'DOM_CPI', 'DEM') > 0"

    "$SHKRESP(2, 'DOM_GDP', 'SUP') < 0"
    "$SHKRESP(2, 'DOM_CPI', 'SUP') > 0"

    "$SHKRESP(3, 'DOM_GDP', 'SUP') < 0"
    "$SHKRESP(3, 'DOM_CPI', 'SUP') > 0"
]

identVerifiables = base.identifier.Verifiables( ...
    signStrings ...
    , maxCandidates=50 ...
);

modelS2 = base.Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS2

modelS2.initialize();
info2 = modelS2.presample(100);
info2

respTbl2 = modelS2.simulateResponses();
respTbl2 = tablex.apply(respTbl2, extremesFunc);
respTbl2 = tablex.flatten(respTbl2);

respTbl2


%% Report details of acceptance statistics 

% * Extract the true-false information about success/fail for in

% trackers = [];
% for s = modelS2.Presampled
%     trackers = [trackers, s{:}.Tracker]; %#ok<AGROW>
% end
% 
% statsTbl = table(mean(trackers, 2), variableNames="Success rate", rowNames=signStrings);
% statsTbl



%% Use a table to specify sign restrictions as a convenience feature 

% * Create an "empty" table designed specifically for sign restrictions using
% `tablex.forSignRestrictions`
% * Fill in `1`s and `-1`s for positive and negative signs
% * The table has variable names in rows, shock names in columns, and each table
% element is a vector of `NaN`s, `1`s and `-1`s corresponding to the periods of
% the identification horizon

rng(0);

signTbl = tablex.forSignRestrictions(modelR);
signTbl{"DOM_GDP", "DEM"} = ">0 [2, 3]";
signTbl{"DOM_CPI", "DEM"} = ">0 [2, 3]";
signTbl{"DOM_GDP", "SUP"} = "<0 [2, 3]";
signTbl{"DOM_CPI", "SUP"} = ">0 [2, 3]";

tablex.validateSignRestrictions(signTbl, model=modelR);

testStrings = base.identifier.SignRestrictions.toVerifiableTestStrings(signTbl, modelR);
testStrings


identVerifiables = base.identifier.Verifiables( ...
    signRestrictionsTable=signTbl, ...
    maxCandidates=50 ...
);


modelS3 = base.Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS3

modelS3.initialize();
info3 = modelS3.presample(100);
info3

respTbl3 = modelS3.simulateResponses();
respTbl3 = tablex.apply(respTbl3, extremesFunc);
respTbl3 = tablex.flatten(respTbl3);

respTbl3



%% Identify a SVAR combining exact zeros and signs 

rng(0);

signTbl0 = tablex.forSignRestrictions(modelR);
signTbl0{"DOM_GDP", "DEM"} = ">0 [2, 3]";
signTbl0{"DOM_CPI", "DEM"} = ">0 [2, 3]";
signTbl0{"DOM_GDP", "SUP"} = "<0 [2, 3]";
signTbl0{"DOM_CPI", "SUP"} = ">0 [2, 3]";

tablex.writetable(signTbl0, "signTbl.xlsx");
signTbl = tablex.readtable("signTbl.xlsx", conversion=@string);


identVerifiables = base.identifier.Verifiables( ...
    signRestrictionsTable=signTbl, ...
    exactZeros=identExactZeros, ...
    maxCandidates=50 ...
);

modelS4 = base.Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS4

modelS4.initialize();
info4 = modelS4.presample(100);
info4

respTbl4 = modelS4.simulateResponses();
respTbl4 = tablex.apply(respTbl4, extremesFunc);
respTbl4 = tablex.flatten(respTbl4);

decomp = modelS4.calculateContributions();

respTbl4

