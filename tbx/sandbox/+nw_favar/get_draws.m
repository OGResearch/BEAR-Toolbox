function [sample, favar] = get_draws(opts, favar)

%%     
pref = struct('excelFile', opts.excelFile, ...
    'results_path', opts.results_path, ...
    'results_sub', opts.results_sub, ...
    'results', opts.results, ...
    'plot', opts.plot, ...
    'workspace', opts.workspace);

[endo, exo, n] = nw_favar.endo_exo(opts);
favar = nw_favar.initfavar(favar);
%% create dates/ranges
startdate=bear.utils.fixstring(opts.startdate);
enddate=bear.utils.fixstring(opts.enddate);

Fstartdate = bear.utils.fixstring(opts.Fstartdate);
Fenddate   = bear.utils.fixstring(opts.Fenddate);

%% load data and get factors

[names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,...
    data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,opts.lambda4,favar]...
    = bear.gensample(startdate,enddate,opts.VARtype,Fstartdate,Fenddate,opts.Fendsmpl,endo,exo,opts.frequency,...
        opts.lags,opts.F,opts.CF,opts.ar,opts.lambda4,opts.PriorExcel,opts.priorsexogenous,pref,favar,opts.IRFt, n);

%% getting X and Y matrices for gibbs sampler
[Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q] = bear.olsvar(data_endo,data_exo,opts.const,opts.lags);

% individual priors 0 for default
for ii=1:n
    for jj=1:m+1
        priorexo(ii,jj) = opts.priorsexogenous;
    end
end

%% variance from univariate OLS for priors
[arvar] = bear.arloop(data_endo,opts.const,p,n);

%% estimating the FAVAR
% [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_nwgibbs(opts.It,opts.Bu,Bhat,EPS,n,m,p,k,T,q,opts.lags,...
%     data_endo,ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,opts.const,data_exo,favar,Y,X);

[prep,favar]=nw_favar.favar_nwprep(Bhat,EPS,n,m,p,k,T,q,opts.lags,data_endo,ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,favar,Y,X);
[sample, fv]=nw_favar.favar_nwsampler(opts.It,n,m,p,k,T,q,opts.lags,ar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,opts.const,...
                    data_exo,favar,Y,X,prep);


%discard Bu and do thinning
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

end                   