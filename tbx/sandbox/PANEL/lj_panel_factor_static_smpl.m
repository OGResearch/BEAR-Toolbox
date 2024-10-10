function outSampler = lj_panel_factor_static_smpl(data_endo,data_exo,const,lags,It,Bu,alpha0,delta0,pick,pickf)

    % compute preliminary elements
    [Ymat, Xmat, N, n, m, p, T, k, q, h]=bear.panel5prelim(data_endo,data_exo,const,lags);

    % use this informations to recreate beta from theta
    % Xmat dimension (Tx(Nnp+m)) - one big matrix
    % Y = X*B
    % X = kron(speye(9),(Xmat))
    % B = Xi*theta

    % obtain prior elements
    [d1, d2, d3, d4, d5, d, Xi1, Xi2, Xi3, Xi4, Xi5, Xi, Y, y, Xtilde, Xdot, theta0, Theta0]=bear.panel5prior(N,n,p,m,k,q,h,T,Ymat,Xmat);

    % start preparing for a sampler
    % compute first  preliminary elements
    % compute alphabar
    alphabar=N*n*T+alpha0;
    % compute the inverse Theta0
    invTheta0=sparse(diag(1./diag(Theta0)));
    % initiate the Gibbs sampler

    % step 1: compute initial values
    % initial value for theta (use OLS values)
    theta=(Xtilde*Xtilde')\(Xtilde*y);
    % initial value for sigmatilde (use residuals form OLS values)
    eps=y-Xtilde'*theta;
    eps=reshape(eps,T,N*n);
    sigmatilde=eps'*eps;
    % initiate value for the sigma, the scaling term for the errors
    sig=1;
    % initiate value for the matrix sigma, the residual variance-covariance matrix
    sigma=sig*sigmatilde;
    % initiate value for eyesigma
    % compute the inverse of sigma
    C=bear.trns(chol(bear.nspd(sigma),'Lower'));
    invC=C\speye(N*n);
    invsigma=invC*invC';
    % then compute eyesigma
    eyesigma=kron(speye(T),invsigma);
    % finally, initiate eyetheta
    eyetheta=kron(speye(T),theta);

    function smpl = sampler()

        % step 2: obtain sigmatilde
        % compute Sbar
        Sbar=(1/sig)*(Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)';
        sigmatilde=bear.iwdraw(Sbar,T);

        % step 3: obtain sig
        % compute the inverse of sigmatilde
        C=bear.trns(chol(bear.nspd(sigmatilde),'Lower'));
        invC=C\speye(N*n);
        invsigmatilde=invC*invC';
        % compute deltabar
        deltabar=trace((Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)'*invsigmatilde)+delta0;
        % draw sig
        sig=bear.igrandn(alphabar/2,deltabar/2);

        % step 4: compute sigma and eyesigma
        sigma=sig*sigmatilde;
        C=bear.trns(chol(bear.nspd(sigma),'Lower'));
        invC=C\speye(N*n);
        invsigma=invC*invC';
        eyesigma=kron(speye(T),invsigma);

        % step 5: obtain theta
        % compute Thetabar
        invThetabar=full((Xtilde*eyesigma*Xtilde'+invTheta0));
        C=bear.trns(chol(bear.nspd(invThetabar),'Lower'));
        invC=C\speye(d);
        Thetabar=invC*invC';
        % compute thetabar
        thetabar=Thetabar*(Xtilde*eyesigma*y+invTheta0*theta0);
        % draw theta
        theta=thetabar+chol(bear.nspd(Thetabar),'lower')*mvnrnd(zeros(d,1),eye(d))';

        % step 6: obtain eyetheta
        eyetheta=kron(speye(T),theta);

        sigma_gibbs = bear.vec(sigma);
        % recalculate beta_gibbs
        beta_gibbs = Xi*theta;

        smpl.beta = beta_gibbs;
        smpl.sigma = sigma_gibbs;
    end
    
    outSampler = @sampler;

    % run the Gibbs sampler
    % [theta_gibbs,sigma_gibbs,sigmatilde_gibbs,sig_gibbs]=bear.panel5gibbs(y,Y,Xtilde,Xdot,N,n,T,d,theta0,Theta0,alpha0,delta0,It,Bu,pick,pickf);

    % compute posterior estimates
    % [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median]=bear.panel5estimates(d,N,n,theta_gibbs,sigma_gibbs,cband);
end