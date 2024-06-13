close all
clear
clear classes
rehash path
addpath ../bear

hist = tablex.fromCsv("exampleData.csv");
dataSpan = tablex.span(hist);

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
YLX = v.getDataYLX(hist, dataSpan);

%%%%obsolete block delete once LHS vars are created loaded elsewhere
opt.excelFile = "C://Git//BEAR-toolbox-6//tbx//replications//data_.xlsx"; %needed for location of lr priors
opt.priorsexogenous  = false; %set true if want to use individual priors for exo 
H = bear.loadH(struct('excelFile', opt.excelFile));

ds = dataSpan(1:meta.Order);
init_endo = nan(numel(ds), 0);
n = numel(meta.EndogenousItems);
for i = 1:numel(meta.EndogenousItems)
    item = meta.EndogenousItems{i};
    init_endo = [init_endo, item.getData(hist, ds, variant=1)];
end

init_exo = nan(numel(ds), 0);
m = numel(meta.ExogenousItems);
for i = 1:m
    item = meta.ExogenousItems{i};
    init_exo = [init_exo, item.getData(hist, ds, variant=1)];
end

for ii=1:n
    for jj=1:m
        priorexo(ii,jj) = opt.priorsexogenous;
        lambda4(ii,jj) = opt.lambda4;
    end
end
opt.lambda4 = lambda4;    
[arvar] = bear.arloop(YLX{1},isa(meta.ExogenousItems(end),"item.Constant"),meta.Order,n);
ar = ones(n,1)*opt.ar;

%%%%obsolete block end

[Ystar, LXstar] = dummy_to_YLX(YLX, init_endo, init_exo,meta.Order, opt, H , ar, arvar, priorexo);

disp(opt)

function [Ystar, LXstar] = dummy_to_YLX(YLX, init_endo, init_exo, order, opt, H, ar, arvar, priorexo)

Ystar = YLX{1};
LXstar = [YLX{2} YLX{3}];

n = size(init_endo,2);
m = size(init_exo,2);

if opt.scoeff
    [Ys, LXs ]  = test.get_scoeff_dummy(init_endo, n,m,order,opt.lambda6);
    Ystar = [Ystar;Ys];
    LXstar = [LXstar;LXs];
end

if opt.iobs
    [Yo, LXo ]  = test.get_iobs_dummy(init_endo,init_exo,order,opt.lambda7);
    Ystar = [Ystar;Yo];
    LXstar = [LXstar;LXo];
end

if opt.lrp
    [Yl, LXl ]  = test.get_lrp_dummy(init_endo,H, n,m,order,opt.lambda8);
    Ystar = [Ystar;Yl];
    LXstar = [LXstar;LXl];
end

if opt.prior == 51
    [Ym, LXm ]  = test.get_min_dummy(n,m,order,ar,arvar,opt.lambda1,opt.lambda3,opt.lambda4,priorexo);
    Ystar = [Ystar;Ym];
    LXstar = [LXstar;LXm];
end

end