
%% Loading data
data_endo = readmatrix("+tv/data_endo.csv");
data_exo = readmatrix("+tv/data_exo.csv");

% load("data.mat")
%% Setting up opt structure
fileName = "+tv/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs ,sigma_t_gibbs, sbar] = tv.get_draws(data_endo, data_exo, opt);

