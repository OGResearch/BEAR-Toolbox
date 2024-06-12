
function outSampler = adapterForSampler(this, meta, YLX)

    arguments
        this
        meta model.ReducedForm.Meta
        YLX (1, 3) cell
    end

    [Y, L, X] = YLX{:};
    init = system.extractInitial(YLX);

    options.Burnin = 0;
    numPresample = 1;
    opt.It = options.Burnin + numPresample;
    opt.Bu = options.Burnin;

    opt = struct();
    opt.priorsexogenous = this.Settings.Exogenous;
    opt.user_ar = this.Settings.Autoregression;
    opt.lambda1 = this.Settings.Lambda1;
    opt.lambda3 = this.Settings.Lambda3;
    opt.lambda4 = this.Settings.Lambda4;

    sigmaAdapter = struct();
    sigmaAdapter.eye = 22;
    sigmaAdapter.ar = 21;
    opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

    opt.const = meta.HasConstant;

    T = size(Y, 1);
    n = size(Y, 2);
    m = size(X, 2);
    pn = size(L, 2);
    p = pn / n;

    k = n * p + m;
    q = n * k;
    % m = k - n * p;
    LX = [L, X];

    opt.p = p;
    priorexo = this.Settings.Exogenous;

    % individual priors 0 for default
    if isscalar(priorexo)
        priorexo = repmat(priorexo, n, m);
    end

    if isscalar(opt.lambda4)
        opt.lambda4 = repmat(opt.lambda4, n, m);
    end

    %create a vector for AR hyperparamters
    ar = ones(n, 1) * this.Settings.Autoregression;

    %variance from univariate OLS for priors
    arvar = bear.arloop([init; Y], opt.const, opt.p, n);

    %setting up prior
    [B0, beta0, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, n, m, opt.p, k, q, ...
        opt.prior, priorexo);

    % obtain posterior distribution parameters
    [Bbar, betabar, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, n, T, k);

    this.SamplerCounter = uint64(0);

    function theta = sampler()
        % [beta_gibbs, sigma_gibbs] = bear.nwgibbs(opt.It, opt.Bu, Bbar, phibar, Sbar, alphabar, alphatilde, n, k);
        B = bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);
        sigma = bear.iwdraw(Sbar,alphabar);
        theta = [B(:); sigma(:)];
        this.SamplerCounter = this.SamplerCounter + 1;
    end%

    outSampler = @sampler;

end%

