
classdef Minnesota < estimator.Base

    methods
        function initializeSampler(this, YLX)
            arguments
                this
                YLX (1, 3) cell
            end
            this.Sampler = this.adapterForSampler(YLX);
        end%


        function outSampler = adapterForSampler(this, YLX)
            %[
            arguments
                this
                YLX (1, 3) cell
            end

            [Y, L, X] = YLX{:};
            init = system.extractInitial(YLX);

            options.Burnin = 0;
            numPresample = 1;
            opt.It = options.Burnin + numPresample;
            opt.Bu = options.Burnin;

            opt.user_ar = this.Settings.Autoregression;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;            
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;
        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, n, m);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.diag = 12;
            sigmaAdapter.ar = 11;
            sigmaAdapter.full = 13;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = this.Settings.HasConstant;

            opt.bex  = this.Settings.BlockExogenous;

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
        %     if isscalar(priorexo)
        %         priorexo = repmat(priorexo, n, m);
        %     end

            %create a vector for AR hyperparamters
        %     if isscalar(this.Settings.Autoregression)
        %         this.Settings.Autoregression = repmat(this.Settings.Autoregression, n, 1);
        %     end
            ar = this.Settings.Autoregression;

            %variance from univariate OLS for priors
            % arvar = bear.arloop([init; Y], opt.const, opt.p, n);
            arvar = bear.arloop([init; Y], opt.const, opt.p, n);

            %setting up prior
            [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, n, m, p, k, q, opt.prior, opt.bex, blockexo, priorexo);
            % obtain posterior distribution parameters
            [betabar, omegabar] = bear.mpost(beta0, omega0, sigma, LX, Y(:), q, n);
            %===============================================================================

            this.SamplerCounter = uint64(0);

            function redSample = sampler()
                beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(q,1);
                redSample = {reshape(beta, 1, 1, []), reshape(sigma, 1, 1, [])};
                this.SamplerCounter = this.SamplerCounter + 1;
            end%

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

