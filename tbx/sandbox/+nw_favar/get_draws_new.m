function [sample, favar] = get_draws_new(opts, favar)

%% load data and get factors

[names,data,data_endo_raw,data_endo_a_raw,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,endo_ix] =...
    nw_favar.gensample_endo(opts);

[data_fv,data_endo_fv,data_endo_a_fv,data_endo_c_fv,data_endo_c_lags_fv,favar, data_endo_orig]=...
    nw_favar.gensample_favar(opts,favar,names);

%% merge the two info

data_endo_mn  = mean(data_endo_raw);
data_endo_std = std(data_endo_raw);
data_endo_dm = (data_endo_raw-data_endo_mn);
data_endo_stand = data_endo_dm/data_endo_std;

%combine variables for data_endo
if favar.onestep
    data_endo(:,endo_ix)  = data_endo_dm;
    data_endo_a(:,endo_ix)  = data_endo_dm;
else
    data_endo(:,endo_ix)  = data_endo_stand; 
    data_endo_a(:,endo_ix)  = data_endo_stand; 
end
data_endo(:,~endo_ix) = data_endo_fv;
data_endo_a(:,~endo_ix) = data_endo_a_fv;

% get the right matrices in the favar object
favar.data_exfactors = data_endo_stand;
favar.data_exfactors_temp = data_endo_dm;
[~,favar]=bear.favar_gensample3([data_fv data_endo_stand ],favar);



%% getting X and Y matrices for gibbs sampler
[Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q] = bear.olsvar(data_endo,data_exo,opts.const,opts.lags);

% individual priors 0 for default
for ii=1:n
    for jj=1:m+1
        priorexo(ii,jj) = opts.priorsexogenous;
        tmp(ii,jj) = opts.lambda4;
    end
end
opts.lambda4 = tmp;
%% variance from univariate OLS for priors
[arvar] = bear.arloop(data_endo,opts.const,p,n);

%% estimating the FAVAR
% [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_nwgibbs(opts.It,opts.Bu,Bhat,EPS,n,m,p,k,T,q,opts.lags,...
%     data_endo,ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,opts.const,data_exo,favar,Y,X);

%create a vector for AR hyperparamters
ar = ones(n,1)*opts.ar;

[prep,favar]=nw_favar.favar_nwprep(Bhat,EPS,n,m,p,k,T,q,opts.lags,data_endo,ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,favar,Y,X);
[sample, fv]=nw_favar.favar_nwsampler(opts.It,n,m,p,k,T,q,opts.lags,ar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,opts.const,...
                    data_exo,favar,Y,X,prep);

thin=abs(round(favar.thin));
name_smpl = ["beta_gibbs","sigma_gibbs"];
for nm = name_smpl
    sample.(nm) = sample.(nm)(:,opts.Bu+1:end);
    if thin~=1
        sample.(nm)=sample.(nm)(:,thin:thin:end);
    end
end

name_smpl = ["X_gibbs","Y_gibbs","FY_gibbs","L_gibbs"];
for nm = name_smpl
    favar.(nm) = fv.(nm)(:,opts.Bu+1:end);
    if thin~=1
        favar.(nm)=favar.(nm)(:,thin:thin:end);
    end
end

opts.It=(1/thin)*opts.It;
opts.Bu=(1/thin)*opts.Bu;

keyboard
end                   