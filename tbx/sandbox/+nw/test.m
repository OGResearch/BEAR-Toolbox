

close all
clear
clear classes
rehash path
addpath ../bear


histLegacy = tablex.fromCsv("exampleDataLegacy.csv", dateFormat="legacy");
hist = tablex.fromCsv("exampleData.csv");

dataSpan = tablex.span(hist);
estimSpan = dataSpan;

metaR = meta.ReducedForm( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"] ...
    , order=4 ...
    , constant=true ...
);

estimator = prior.NormalWishart(autoregression=1);

r = model.ReducedForm(meta=metaR, estimator=estimator);

id = identification.Triangular(stdVec=1);
metaS = meta.Structural(shockNames=["e1", "e2", "e3"]);

s = model.Structural(meta=metaS, reducedForm=r, identification=id);

prctileFunc = @(x) prctile(x, [5, 50, 95], 2);

% r.initialize(hist, estimSpan);
s.initialize(hist, estimSpan);
s.presample(100);

shockSpan = datex.span(datex.q(1,1), datex.q(4,4));

shocks = s.simulateShocks(shockSpan, shockIndex=["e2", "e3"]);
fevd = s.fevd(shockSpan);

shocksPrctiles = tablex.apply(shocks, prctileFunc);


rng(0);
N = 10000;

disp("Presampling...")
r.presample(N);
r.Estimator.SamplerCounter

amean = s.asymptoticMean();

endHist = estimSpan(end);
% startForecast = datex.shift(endHist, -11);
% endForecast = datex.shift(endHist, 0);
startForecast = datex.shift(endHist, 1);
endForecast = datex.shift(endHist, 100);
forecastSpan = datex.span(startForecast, endForecast);

rng(0);
disp("Forecasting...")
fcast = s.forecast(hist, forecastSpan);
clippedHist = tablex.clip(hist, endHist, endHist);


fcastPrctiles = tablex.apply(fcast, prctileFunc);
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


