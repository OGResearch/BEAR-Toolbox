
classdef ...
    NormalWishartEstimator ...
    < var.AbstractEstimator

    methods
        function this = NormalWishartEstimator(varargin)
            this.PriorSettings = var.settings.NormalWishartPriorSettings(varargin{:});
        end%

        function sampler = initializeAdapter(this, meta, YX, options)
            arguments
                this
                meta (1, 1) var.Meta
                YX (1, 2) cell
                options.Burnin (1, 1) double = NaN
            end

            options.Burnin = 0;

            [Y, X] = YX{:};

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

            numPresample = 1;
            opt.It = options.Burnin + numPresample;
            opt.Bu = options.Burnin;

            [T, n] = size(Y);
            [~ , k] = size(X);
            q = n*k;
            m = k - n * meta.Order;

            % individual priors 0 for default
            priorexo = repmat(this.PriorSettings.Exogenous, n, m);

            %create a vector for AR hyperparamters
            ar = ones(n, 1) * this.PriorSettings.Autoregressive;

            %variance from univariate OLS for priors
            arvar = bear.arloop(Y, opt.const, opt.p, n);

            %setting up prior
            [B0, beta0, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, n, m, opt.p, k, q, ...
                opt.prior, priorexo);
            % obtain posterior distribution parameters
            [Bbar, betabar, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, X, Y, n, T, k);
            [beta_gibbs, sigma_gibbs] = bear.nwgibbs(opt.It, opt.Bu, Bbar, phibar, Sbar, alphabar, alphatilde, n, k);

            function theta = sampler__()
                B = bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);
                sigma = bear.iwdraw(Sbar,alphabar);
                theta = [B(:); sigma(:)];
            end%

            sampler = @sampler__;
        end%
    end

end

