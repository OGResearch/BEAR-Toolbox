function [prep,favar]=favar_nwprep(Bhat,EPS,n,m,p,k,T,q,lags,data_endo,ar,arvar,lambda1,lambda3,lambda4,prior,priorexo,favar,Y,X)
    
%% preliminary tasks
% initialise variables

prep.favarX=favar.X(:,favar.plotX_index);
prep.favarplotX_index=favar.plotX_index;
prep.onestep=favar.onestep;
% initial conditions XZ0~N(XZ0mean,XZ0var)
favar.XZ0mean=zeros(n*lags,1);
favar.XZ0var=favar.L0*eye(n*lags); %BBE set-up

prep.XY=favar.XY;
prep.L=favar.L;
prep.Sigma=bear.nspd(favar.Sigma);
if prep.onestep==1
    prep.indexnM=favar.indexnM;
else
    prep.indexnM=[];
end
prep.XZ0mean=favar.XZ0mean;
prep.XZ0var=favar.XZ0var;
prep.favar_X=favar.X;
% load priors
prep.L0=favar.L0*eye(n);
prep.a0=favar.a0;
prep.b0=favar.b0;
sigmahat=(1/T)*(EPS'*EPS);

% preallocation
prep.beta_gibbs=zeros(size(Bhat(:),1),0);
prep.sigma_gibbs=zeros(size(sigmahat(:),1),0);
prep.X_gibbs=zeros(size(X(:),1),0);
prep.Y_gibbs=zeros(size(Y(:),1),0);
prep.FY_gibbs=zeros(size(data_endo(:),1),0);
prep.L_gibbs=zeros(size(prep.L(:),1),0);
prep.R2_gibbs=zeros(size(prep.favarX,2),0);

if prep.onestep==0 %static factors in this case
    prep.FY=data_endo;
else
    prep.FY = [];
end




% state-space representation
if prep.onestep==1
    prep.B_ss=[Bhat';eye(n*(lags-1)) zeros(n*(lags-1),n)];
    prep.sigma_ss=[sigmahat zeros(n,n*(lags-1));zeros(n*(lags-1),n*lags)];
   
   prep.Bbar = [];
   prep.phibar = [];
   prep.Sbar = [];
   prep.alphabar = [];  
   prep.alphatilde = [];


elseif prep.onestep==0
    % set prior values
    [B0,~,phi0,S0,alpha0]=bear.nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
    % obtain posterior distribution parameters
    [prep.Bbar,~,prep.phibar,prep.Sbar,prep.alphabar,prep.alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k);

    prep.B_ss = [];
    prep.sigma_ss = [];
end

    
