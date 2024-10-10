function [outSampler, X, Y] = lj_panel_rand_eff_hier_smpl(data_endo,data_exo,const,lags,lambda2,lambda3,lambda4,It,Bu,s0,v0,pick,pickf)

    % compute preliminary elements
    [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel4prelim(data_endo,data_exo,const,lags);

    % obtain prior elements
    [omegab]=bear.panel4prior(N,n,m,p,T,k,data_endo,q,lambda3,lambda2,lambda4);
    
    % compute first  preliminary elements
    % compute sbar
    sbar=h+s0;

    % compute the inverse of omegab
    invomegab=diag(1./diag(omegab));

    % initiate the record matrices
    % beta_gibbs=zeros(q,It-Bu,N);
    % sigma_gibbs=zeros(n^2,It-Bu,N);
    % beta_mean=zeros(q,It-Bu);
    % sigma_mean=zeros(n^2,It-Bu);
    % lambda_posterior=zeros((It-Bu),1);

    % step 1: compute initial values
    % initial value for beta (use OLS values)
    for ii=1:N
      beta_init(:,ii)=bear.vec((Xi(:,:,ii)'*Xi(:,:,ii))\(Xi(:,:,ii)'*Yi(:,:,ii)));
    end

    % initial value for b
    % Actually not used!!!
    b=(1/N)*sum(beta_init,2);

    % initial value for lambda1
    lambda1=0.01;
    sigmab=lambda1*omegab;

    % initial value for sigma (use OLS values)
    for ii=1:N
      eps=Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta_init(:,ii),k,n);
      sigma(:,:,ii)=(1/(T-k-1))*eps'*eps;
    end

    beta = beta_init;

    % sampler will be a function
    function smpl = sampler()

      % step 2: obtain b
      % first compute betam, the mean value of the betas over all units
      betam=(1/N)*sum(beta,2);
      % draw b from a multivariate normal N(betam,(1/N)*sigmab))
      b=betam+chol(bear.nspd((1/N)*sigmab),'lower')*mvnrnd(zeros(q,1),eye(q))';

      % step 3: obtain sigmab
      % compute first vbar
      for ii=1:N
          temp(1,ii)=(beta(:,ii)-b)'*invomegab*(beta(:,ii)-b);
      end

      vbar=v0+sum(temp,2);

      % compute lambda1
      lambda1=bear.igrandn(sbar/2,vbar/2);

      % recover sigmab
      sigmab=lambda1*omegab;

      % step 4: draw the series of betas
      % first obtain the inverse of sigmab
      invsigmab=diag(1./diag(sigmab));
      
      % then loop over units
      for ii=1:N

        % take the choleski factor of sigma of unit ii, inverse it, and obtain from it the inverse of the original sigma
        C=bear.trns(chol(bear.nspd(sigma(:,:,ii)),'Lower'));
        invC=C\speye(n);
        invsigma=invC*invC';

        % obtain omegabar
        invomegabar=kron(invsigma,Xi(:,:,ii)'*Xi(:,:,ii))+invsigmab;

        % invert
        C=bear.trns(chol(bear.nspd(invomegabar),'Lower'));
        invC=C\speye(q);
        omegabar=invC*invC';

        % obtain betabar
        betabar=omegabar*(kron(invsigma,Xi(:,:,ii)')*bear.vec(Yi(:,:,ii))+invsigmab*b);

        % draw beta
        beta(:,ii)=betabar+chol(bear.nspd(omegabar),'lower')*mvnrnd(zeros(q,1),eye(q))';

        beta_gibbs(:,ii)=beta(:,ii);
      end

      % step 5: draw the series of sigmas
      % loop over units
      for ii=1:N

        % compute Stilde
        Stilde=(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,n))'*(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,n));

        % draw sigma
        sigma(:,:,ii)=bear.iwdraw(Stilde,T);

        sigma_gibbs(:,ii)=bear.vec(sigma(:,:,ii));
      end

      beta_mean=b;
      sigma_mean=bear.vec(mean(sigma,3));
      lambda_posterior=lambda1;
      smpl = struct();
      smpl.beta = beta_gibbs;
      smpl.sigma = sigma_gibbs;
      
    end

    outSampler = @sampler;
end