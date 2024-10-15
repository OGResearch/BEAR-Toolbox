
classdef Minnesota < estimator.Base

    methods
        function initializeSampler(this, YXZ)
            arguments
                this
                YXZ (1, 3) cell
            end
            this.Sampler = this.adapterForSampler(YXZ);
        end%


        function outSampler = adapterForSampler(this, YXZ)
            %[
            arguments
                this
                YXZ (1, 3) cell
            end

            [Y_long, X_long, ~] = YXZ{:};

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
            opt.p = this.Settings.Order;
            
            opt.bex  = this.Settings.BlockExogenous;

           [~, ~, ~, LX, ~, Y, ~, ~, ~, n, m, ~, ~, k, q] = bear.olsvar(Y_long, X_long, opt.const, opt.p);


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
             arvar = bear.arloop(Y_long, opt.const, opt.p, n);

            %setting up prior
            [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, n, m, p, k, q, opt.prior, opt.bex, blockexo, priorexo);
            % obtain posterior distribution parameters
            [betabar, omegabar] = bear.mpost(beta0, omega0, sigma, LX, Y(:), q, n);
            %===============================================================================

            this.SamplerCounter = uint64(0);

            function smpl = sampler()
                beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(q,1);
                smpl.beta = beta;
                smpl.sigma = sigma;
                this.SamplerCounter = this.SamplerCounter + 1;
            end%

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

