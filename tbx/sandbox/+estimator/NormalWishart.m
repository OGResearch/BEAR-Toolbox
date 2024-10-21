
classdef NormalWishart < estimator.Base

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
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, numEn, numEx);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = this.Settings.HasConstant;
            opt.p = this.Settings.Order;
           
            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, ~, estimLength, numBRows, sizeB] = ...
                bear.olsvar(Y_long, X_long, opt.const, opt.p);

            priorexo = this.Settings.Exogenous;

            % individual priors 0 for default
        %     if isscalar(priorexo)
        %         priorexo = repmat(priorexo, numEn, numEx);
        %     end

            %create a vector for AR hyperparamters
        %     if isscalar(this.Settings.Autoregression)
        %         this.Settings.Autoregression = repmat(this.Settings.Autoregression, numEn, 1);
        %     end
            ar = this.Settings.Autoregression;

            %variance from univariate OLS for priors
            arvar = bear.arloop(Y_long, opt.const, opt.p, numEn);

            %setting up prior
            [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4,...
                numEn, numEx, opt.p, numBRows, sizeB, opt.prior, priorexo);

            % obtain posterior distribution parameters
            [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, numEn, estimLength, numBRows);

            %===============================================================================

            this.SamplerCounter = uint64(0);

            function sampleStruct = sampler()
                % [beta_gibbs, sigma_gibbs] = bear.nwgibbs(opt.It, opt.Bu, Bbar, phibar, Sbar, alphabar, alphatilde, numEn, numBRows);
                B = bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,numBRows,numEn);
                sigma = bear.iwdraw(Sbar,alphabar);
                sampleStruct.B = B;
                sampleStruct.sigma = sigma;
                this.SamplerCounter = this.SamplerCounter + 1;
            end%

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

