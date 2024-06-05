

close all
clear


tt = tablex.fromCsv("exampleData.csv");

mv = MetaVAR(["DOM_GDP", "DOM_CPI", "STN"], order=4, constant=true);


