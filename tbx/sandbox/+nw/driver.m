
%% Loading data
Y = readmatrix("+nw/Y.csv");
X = readmatrix("+nw/X.csv");

% load("data.mat")
%% Setting up opt structure
fileName = "+nw/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

% opt.priorsexogenous = 0;
% 
% % hyperparameters
% opt.user_ar = 1;
% opt.lambda1 = 0.1;
% opt.lambda3 = 1;
% opt.lambda4 = 100;
% 
% %prior type
% opt.prior = 21; %NW, S0 as univariate AR with 
% 
% %data matrices and sizes
% opt.p          = 4; 
% opt.const      = true;
% 
% %Settings for sampling
% opt.It = 2000;
% opt.Bu = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs, sigma_gibbs] = nw.get_draws(Y, X, opt);

