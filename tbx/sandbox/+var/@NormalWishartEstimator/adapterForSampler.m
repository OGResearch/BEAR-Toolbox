
function outSampler = adapterForSampler(this, meta, YX)

    arguments
        this
        meta var.Meta
        YX (1, 2) cell
    end

    [Y, X] = YX{:};

    options.Burnin = 0;
    numPresample = 1;
    opt.It = options.Burnin + numPresample;
    opt.Bu = options.Burnin;

    opt = struct();
    opt.priorsexogenous = this.PriorSettings.Exogenous;
    opt.user_ar = this.PriorSettings.Autoregressive;
    opt.lambda1 = this.PriorSettings.Lambda1;
    opt.lambda3 = this.PriorSettings.Lambda3;
    opt.lambda4 = this.PriorSettings.Lambda4;

    sigmaAdapter = struct();
    sigmaAdapter.eye = 22;
    sigmaAdapter.ar = 21;
    opt.prior = sigmaAdapter.(lower(this.PriorSettings.Sigma));

    opt.p = meta.Order;
    opt.const = meta.HasConstant;

    numEndogenousColumns = meta.NumEndogenousColumns;
    numExogenousColumns = meta.NumExogenousColumns;
    numPeriods = size(Y, 1);

    T = numPeriods;
    n = meta.NumLhsColumns;
    k = meta.NumRhsColumns;
    p = meta.Order;

    % [T, n] = size(Y);
    % [~ , k] = size(X);

    q = n * k;
    m = k - n * p;

    % individual priors 0 for default
    priorexo = repmat( ...
        this.PriorSettings.Exogenous ...
        , numEndogenousColumns ...
        , numExogenousColumns ...
    );

    %create a vector for AR hyperparamters
    ar = ones(n, 1) * this.PriorSettings.Autoregressive;

    %variance from univariate OLS for priors
    arvar = bear.arloop(Y, opt.const, opt.p, n);

    %setting up prior
    [B0, beta0, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, n, m, opt.p, k, q, ...
        opt.prior, priorexo);

    % obtain posterior distribution parameters
    [Bbar, betabar, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, X, Y, n, T, k);

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

