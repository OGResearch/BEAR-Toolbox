

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

data_endo = nan(numel(dataSpan), 0);
for i = 1:numel(meta.EndogenousItems)
    item = meta.EndogenousItems{i};
    data_endo = [data_endo, item.getData(hist, dataSpan, variant=1)];
end

constant_flag = isa(meta.ExogenousItems{end},'item.Constant');
data_exo = nan(numel(dataSpan), 0);
for i = 1:numel(meta.ExogenousItems) - double(constant_flag)
    item = meta.ExogenousItems{i};
    data_exo = [data_exo, item.getData(hist, dataSpan, variant=1)];
end

v = model.ReducedForm( ...
    meta=meta, ...
    estimator=prior, ...
    dummies={d1, d2, d3, d4} ...
);


opt = dummies.populateLegacyOptions(v.Dummies);
opt.excelFile = "C://Git//BEAR-toolbox-6//tbx//replications//data_.xlsx"; %needed for location of lr priors
opt.priorsexogenous  = false; %set true if want to use individual priors for exo 


YLX = v.getDataYLX(hist, dataSpan);

[Ystar, LXstar] = dummy_to_YLX(opt,meta.Order,constant_flag, data_endo,data_exo, YLX);

disp(opt)

function [Ystar, LXstar] = dummy_to_YLX(opt,order,constant, data_endo,data_exo, YLX)

Y = YLX{1};
X = [YLX{2} YLX{3}];

n = size(data_endo,2);
T = size(data_endo,1);
m = size(data_exo,2) + constant;

H = [];
if opt.lrp==1
    H=bear.loadH(struct('excelFile', opt.excelFile));
end


[Ystar, ~, Xstar, Tstar, ~, ~, ~, ~] = ...
    bear.gendummy(data_endo,data_exo,Y,X,n,m,order,T,constant,opt.lambda6,opt.lambda7,opt.lambda8,opt.scoeff,opt.iobs,opt.lrp,H);

if opt.prior == 51

    for ii=1:n
        for jj=1:m
            priorexo(ii,jj) = opt.priorsexogenous;
        end
    end
    
    [arvar] = bear.arloop(Y,constant,order,n);
    ar = ones(n,1)*opt.ar;
    [Ystar,LXstar,Tstar]=bear.doprior(Ystar,Xstar,n,m,order,Tstar,ar,arvar,opt.lambda1,opt.lambda3,opt.lambda4,priorexo);


end
end