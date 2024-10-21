
classdef NormalWishart < estimator.Base

    properties
        CanHaveDummies = true
        CanHaveReducibles = false
    end

    methods
        function initializeSampler(this, meta, longYXZ, dummiesYLX)
            %[
            arguments
                this
                meta (1, 1) meta.ReducedForm
                longYXZ (1, 3) cell
                dummiesYLX (1, 3) cell
            end

            [longY, longX, ~] = longYXZ{:};

            options.Burnin = 0;
            numPresample = 1;
            opt.It = options.Burnin + numPresample;
            opt.Bu = options.Burnin;

            opt.user_ar = this.Settings.Autoregression;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, n, m);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, n, m, ~, T, k, q] = bear.olsvar(longY, longX, opt.const, opt.p);

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
            arvar = bear.arloop(longY, opt.const, opt.p, n);

            %setting up prior
            [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, n, m, opt.p, k, q, ...
                opt.prior, priorexo);

            % obtain posterior distribution parameters
            [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, n, T, k);
            %
            function sample = sampler()
                % [beta_gibbs, sigma_gibbs] = bear.nwgibbs(opt.It, opt.Bu, Bbar, phibar, Sbar, alphabar, alphatilde, n, k);
                B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, k, n);
                Sigma = bear.iwdraw(Sbar, alphabar);
                sample.B = B;
                sample.Sigma = Sigma;
                this.SamplerCounter = this.SamplerCounter + 1;
            end%
            %
            this.Sampler = @sampler;
            %]
        end%


        function createDrawers(this, meta)
            %[
            numY = meta.NumEndogenousNames;
            order = meta.Order;
            %
            function draw = unconditionalDrawer(sample, start, horizon)
                A = sample.B(1:numY*order, :);
                C = sample.B(numY*order+1:end, :);
                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                draw.Sigma = repmat({sample.Sigma}, horizon, 1);
            end%
            %
            function draw = identificationDrawer(sample, horizon)
                A = sample.B(1:numY*order, :);
                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.Sigma = sample.Sigma;
            end%
            %
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = [];
            this.IdentificationDrawer = @identificationDrawer;
            %]
        end%
    end

end

