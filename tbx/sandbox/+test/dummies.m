
close all
clear
clear classes
rehash path
addpath ../bear

d1 = dummies.InitialObservations(tightness=2);
d2 = dummies.Minnesota(ExogenousTightness=30);
d3 = dummies.LongRun(Tightness=0.45);
d4 = dummies.SumCoefficients(Tightness=0.45);

meta = model.ReducedForm.Meta( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"] ...
    , order=4 ...
    , constant=true ...
);

prior = prior.NormalWishart();

v = model.ReducedForm( ...
    meta=meta, ...
    estimator=prior, ...
    dummies={d1, d2, d3, d4} ...
);

opt = dummies.populateLegacyOptions(v.Dummies);

disp(opt)

