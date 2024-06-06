

close all
clear


tt = tablex.fromCsv("exampleData.csv");

dataSpan = tablex.span(tt);

v = var.ReducedForm( ...
    meta={"endogenous", ["DOM_GDP", "DOM_CPI", "STN"], "order", 4, "constant", true, } ...
    , priors={"NormalWishart", } ...
);

YX = v.Meta.getData(tt, dataSpan);

oldY = readmatrix("+nw/Y.csv");
oldX = readmatrix("+nw/X.csv");

[Y, X] = YX{:};
max(abs(Y - oldY), [], "all")

v.initialize(tt, dataSpan)

v.presample(1000);

