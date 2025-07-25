
classdef NormalWishartFAVARTwostep < estimator.BaseFAVAR & estimator.PlainFAVARDrawersMixin
%% BFAVAR with Normal-Wishart prior and two-step estimation
% FAVAR version of prior =21 22 in BEAR5

    methods (Static)
        function info = getModelReference()
            info.category = "favar";
        end
    end

    properties
        DescriptionUX = "BFAVAR with Normal-Wishart prior"

        CanHaveDummies = false
        
        HasCrossUnits = false

        Category = "Plain BFAVAR estimators"

        %Struct identification
        CanBeIdentified = true        
    end


    methods

        function initializeSampler(this, meta, longYXZ)
            %[
            arguments
                this
                meta (1, 1) model.Meta
                longYXZ (1, 3) cell
            end

            longX = longYXZ{2};

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;

            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            %% FAVAR settings, maybe we can move this to a separate function

            favar = this.FAVAR;
            FY = favar.FY;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = bear.olsvar(FY, longX, ...
                opt.const, opt.p);

            % set prior values
            [arvar] = bear.arloop(FY, opt.const, p, numEn);
            [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, numEn, numEx, p, ...
                numBRows, sizeB, opt.prior, priorexo);

            % obtain posterior distribution parameters
            [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, numEn, estimLength, numBRows);

            LD = favar.L;
            
            %===============================================================================

            function sample = sampler()

                stationary=0;

                while stationary==0
                    B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, numBRows, numEn);
                    [stationary] = bear.checkstable(B(:), numEn, p, size(B, 1)); %switches stationary to 0, if the draw is not stationary
                end

                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma = bear.iwdraw(Sbar,alphabar);

                sample.beta = B(:);
                sample.sigma = sigma;
                sample.FY = FY;
                sample.LD = LD;
                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%

    end

end

