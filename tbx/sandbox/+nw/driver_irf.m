%% Loading data

beta_gibbs = readmatrix("+nw/beta_gibbs.csv");
sigma_gibbs = readmatrix("+nw/sigma_gibbs.csv");

%% Setting up opt structure
fileName = "+nw/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

favar.FAVAR = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[irf_estimates,D_estimates,gamma_estimates,favar]= nw.run_irf(beta_gibbs, sigma_gibbs, opt,favar);