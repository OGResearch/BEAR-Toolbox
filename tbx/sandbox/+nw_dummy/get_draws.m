function [beta_gibbs, sigma_gibbs] =...
    get_draws(data_endo,data_exo, opts)

pref = struct('excelFile', opts.excelFile);


[Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,opts.const,opts.lags);

%variance from univariate OLS for priors
[arvar] = bear.arloop(Y,opts.const,p,n);

%create a vector for AR hyperparamters
ar = ones(n,1)*opts.user_ar;

% individual priors 0 for default
for ii=1:n
    for jj=1:m
        priorexo(ii,jj) = opts.priorsexogenous;
    end
end


H=[];
if (opts.VARtype==2) && opts.lrp==1
    H=bear.loadH(pref);
end

[Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum]=nw_dummy.gendummy_local(data_endo,data_exo,Y,X,n,m,p,T,opts.const,...
    opts.lambda1,opts.lambda3, opts.lambda4,opts.lambda6,opts.lambda7,opts.lambda8,...
    opts.scoeff,opts.iobs,opts.lrp,opts.mindum, H, ar, arvar, priorexo);
keyboard
%setting up prior
[B0,beta0,phi0,S0,alpha0] = bear.nwprior(ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,n,m,p,k,q,...
    opts.prior,priorexo);
% obtain posterior distribution parameters
[Bbar,betabar,phibar,Sbar,alphabar,alphatilde] = bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
[beta_gibbs,sigma_gibbs] = bear.nwgibbs(opts.It,opts.Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);