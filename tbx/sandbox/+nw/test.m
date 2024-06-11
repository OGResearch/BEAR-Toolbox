

close all
clear
clear classes
rehash path
addpath ../bear


hist = tablex.fromCsv("exampleData.csv");

dataSpan = tablex.span(hist);

meta = model.ReducedForm.Meta( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"] ...
    , order=4 ...
    , constant=true ...
)

prior = prior.NormalWishart();

d1 = dummies.InitialObservations(tightness=2);
d2 = dummies.Minnesota(ExogenousTightness=30);
d3 = dummies.LongRun(Tightness=0.45);
d4 = dummies.SumCoefficients(Tightness=0.45);

allDummies = {d1, d2, d3, d4};
return

v = model.ReducedForm(meta=meta, estimator=prior, dummies=allDummies);

return

v.initialize(hist, dataSpan);

% sm = structural.Meta(rm);
% 
% id = structural.Cholesky();
% 
% s = structural.Model(meta=sm, reducedForm=v, identifier=id);

rng(0);

N = 1000;
v.presample(N, stability="stationary");
v.Estimator.SamplerCounter

% v.presample(N, stability="stationary");
% v.Estimator.SamplerCounter

endHist = dataSpan(end);
% startForecast = datex.shift(endHist, -11);
% endForecast = datex.shift(endHist, 0);
startForecast = datex.shift(endHist, 1);
endForecast = datex.shift(endHist, 100);
forecastSpan = datex.span(startForecast, endForecast);


fcast = v.forecast(hist, forecastSpan);
clippedHist = tablex.clip(hist, endHist, endHist);

fcastPrctiles = tablex.apply(fcast, @(x) prctile(x, [5, 50, 95], 2));
fcastPrctiles = tablex.merge(clippedHist, fcastPrctiles);

fcastMean = tablex.apply(fcast, @(x) mean(x, 2));
fcastMean = tablex.merge(clippedHist, fcastMean);

tiledlayout(2, 2);
for n = ["DOM_GDP", "DOM_CPI", "STN"]
    nexttile();
    hold on
    h = tablex.plot(fcastPrctiles, n);
    set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.5, 0.8, 0.8]);
    h = tablex.plot(hist, n);
    set(h, color="black", lineWidth=2);
end


