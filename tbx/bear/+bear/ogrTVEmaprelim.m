function [Y, X, n, p, T, k1, q1] = ogrTVEmaprelim(longY, lags)

p = lags;

% then compute n, the number of endogenous variables in the model; it is simply the number of columns in the matrix 'longY'
n = size(longY, 2);

% estimate k1, the number of parameters related to endogenous variables in each equation, defined p77
k1 = n*p;

% estimate q1, the total number of parameters related to endogenous variables, defined p77
q1 = n*k1;

% obtain the matrices Y and X, defined in (3.6.10)
% to do so, use the lagx function on the data matrix
temp = bear.lagx(longY, lags);

% % to build X, take off the n initial columns of current data
X = temp(:, n + 1:end);
% 
% % save the n first columns of temp as Y
Y = temp(:, 1:n);

% Define T, the number of periods of the model, as the number of rows of Y
T = size(temp(:, 1:n), 1);