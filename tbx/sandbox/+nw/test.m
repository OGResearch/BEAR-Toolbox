

close all
clear
clear classes
rehash path
addpath ../bear

rng(0);

pctileFunc = @(x) prctile(x, [5, 50, 95], 2);

master = bear6.run(configFile="+nw/config.toml");
config = master.Config;

% histLegacy = tablex.fromCsv("exampleDataLegacy.csv", dateFormat="legacy");
% hist = tablex.fromCsv("exampleData.csv");

hist = master.InputData;

dataSpan = tablex.span(hist);
estimSpan = dataSpan;

metaR = meta.ReducedForm( ...
    endogenous=config.meta.endogenous ...
    , order=config.meta.order ...
    , constant=config.meta.constant ...
);


estimator = estimator.(config.estimator.method)(autoregression=1);

r = model.ReducedForm(meta=metaR, estimator=estimator);

r.initialize(hist, estimSpan);
% r.presample(100);
residTbl = r.residuals(hist);

% id = identifier.Triangular(stdVec=1);

id = identifier.Custom( ...
    exact=config.identifier.settings.exact, ...
    verifiable=config.identifier.settings.verifiable ...
);

metaS = meta.Structural(config.meta.shocks);

s = model.Structural(meta=metaS, reducedForm=r, identifier=id);

% r.initialize(hist, estimSpan);
s.initialize(hist, estimSpan);
s.presample(100);

shockSpan = datex.span(datex.q(1,1), datex.q(10,4));

fevd = s.fevd(shockSpan);

shockTbl = s.simulateShocks(shockSpan);
shockPctileTbl = tablex.apply(shockTbl, pctileFunc);
tiledlayout(3, 3);
time = 0 : numel(shockPctileTbl.Time)-1;
for n = ["DOM_GDP", "DOM_CPI", "STN"]
    for i = 1 : 3
        shockName = s.Meta.ShockNames(i);
        nexttile();
        hold on
        data = shockPctileTbl.(n)(:, :, i);
        h = plot(time, data);
        set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.3, 0.6, 0.6]);
        title(n + " <-- " + shockName, interpreter="none");
    end
end

return

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


fcastPctiles = tablex.apply(fcast, pctileFunc);
fcastPctiles = tablex.merge(clippedHist, fcastPctiles);

fcastMean = tablex.apply(fcast, @(x) mean(x, 2));
fcastMean = tablex.merge(clippedHist, fcastMean);

tiledlayout(2, 2);
for n = ["DOM_GDP", "DOM_CPI", "STN"]
    nexttile();
    hold on
    h = tablex.plot(fcastPctiles, n);
    set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.5, 0.8, 0.8]);
    h = tablex.plot(hist, n);
    set(h, color="black", lineWidth=2);
end

