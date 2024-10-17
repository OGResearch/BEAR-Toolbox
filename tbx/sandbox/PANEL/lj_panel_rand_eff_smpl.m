function outSampler = lj_panel_rand_eff_smpl(data_endo,data_exo,const,lags,lambda1)

    % compute preliminary elements
    [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel3prelim(data_endo,data_exo,const,lags);

    % obtain prior elements
    [b, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);

    % compute posterior distribution parameters
    [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);
    
    % sampler will be a function
    function smpl = sampler()

      % draw a random vector beta from N(betabar,omegabarb)
      % TODO - optimize chol (can be run only once)
      beta=betabar+chol(bear.nspd(omegabarb),'lower')*mvnrnd(zeros(h,1),eye(h))';

      beta=reshape(beta,q,N);
      % record values by marginalising over each unit
      for jj=1:N

        beta_gibbs(:,jj)=beta(:,jj);

      end

      % obtain a record of draws for sigma, the residual variance-covariance matrix
      % compute sigma
      sigma=sigeps*eye(n);

      sigma_gibbs=repmat(sigma(:),[1 N]);
      
      smpl = struct();
      smpl.beta = beta_gibbs;
      smpl.sigma = sigma_gibbs;

    end

    outSampler = @sampler;
end