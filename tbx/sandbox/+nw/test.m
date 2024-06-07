

close all
clear


hist = tablex.fromCsv("exampleData.csv");

dataSpan = tablex.span(hist);

v = var.ReducedForm( ...
    meta={"endogenous", ["DOM_GDP", "DOM_CPI", "STN"], "order", 4, "constant", true, } ...
    , priors={"NormalWishart", } ...
);

YX = v.Meta.getDataYX(hist, dataSpan);

oldY = readmatrix("+nw/Y.csv");
oldX = readmatrix("+nw/X.csv");

[Y, X] = YX{:};
max(abs(Y - oldY), [], "all")

v.initialize(hist, dataSpan);

rng(0);

N = 1000;
v.presample(N, stability="stationary");
v.Estimator.SamplerCounter

% v.presample(N, stability="stationary");
% v.Estimator.SamplerCounter

endHist = dataSpan(end);
startForecast = datex.shift(endHist, 1);
endForecast = datex.shift(endHist, 12);
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
    h = plot(fcastPrctiles.Time, fcastPrctiles.(n));
    set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.5, 0.8, 0.8]);
    plot(hist.Time, hist.(n), color="black", lineWidth=2);
end


