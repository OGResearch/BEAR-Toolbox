function [beta_gibbs, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs ,sigma_t_gibbs, sbar] =...
    get_draws(data_endo,data_exo, opt)

%beta_gibbs: 3D array for beta draws
%omega_gibbs: covriance matrix for the RW process of betas
%sigma_gibbs
%F_gibbs: 3D array lower triangular matrix  where sigma_t_gibbs = F_gibbs*lambda_t_gibbs*F_gibbs'
%L_gibbs tv lambdas
%phi_gibbs: heteroscedasticity parameters (variance of lambdas)
%sigma_t_gibbs: see above
%lambda_t_gibbs: time varying diagonal matrix generating the
%heteroscedasticity (s_bar*exp(lambda) in the diagonal)
%sbar: scaling parameters, s
%sigma_gibbs F_gibbs*diag(sbar)*F_gibbs'

[Bhat, betahat, sigmahat, X, ~, Y, ~, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,opt.const,opt.lags);
[arvar]=bear.arloop(data_endo,opt.const,p,n);
[yt, y, Xt, Xbart, Xbar]=bear.tvbvarmat(Y,X,n,q,T);
[chi, psi, kappa, S, H, I_tau, G, I_om, f0, upsilon0] = bear.tvbvar2prior(arvar,n,q,T,opt.gamma);
[beta_gibbs, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs ,sigma_t_gibbs, sbar]...
        =bear.tvbvar2gibbs(G,sigmahat,T,chi,psi,kappa,betahat,q,n,...
        opt.It,opt.Bu,I_tau,I_om,H,Xbar,y,opt.alpha0,yt,Xbart,upsilon0,f0,opt.delta0,opt.gamma,opt.pick,opt.pickf);