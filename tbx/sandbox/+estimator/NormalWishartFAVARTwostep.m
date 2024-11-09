
classdef NormalWishartFAVARTwostep < estimator.Base

    properties
        DescriptionUX = "BFAVAR with Normal-Wishart prior"

        CanHaveDummies = false
        CanHaveReducibles = true
        HasCrossUnits = false
    end


    methods

        function initializeSampler(this, meta, longYXZ, dummiesYLX)
            %[
            arguments
                this
                meta (1, 1) meta.ReducedForm
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, longZ] = longYXZ{:};

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.user_ar = this.Settings.Autoregression;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

            opt.L0 = this.Settings.LoadingVariance;
            opt.a0 = this.Settings.SigmaShape;
            opt.b0 = this.Settings.SigmaScale;

            opt.numpc = this.Settings.NumFactors;

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;

            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = false;
            [favar.l] =pca(longZ,'NumComponents',opt.numpc);

            favar.nfactorvar = size(longZ, 2);

            %identify factors: normalise loadings, compute factors following BBE 2005
            favar.l = sqrt(favar.nfactorvar) * favar.l;
            favar.XZ = longZ * favar.l / favar.nfactorvar;

            data_endo = [favar.XZ longY];

            favar.variablestrings_factorsonly = (1:favar.numpc)';
            favar.variablestrings_factorsonly_index = [true(favar.numpc, 1) ; false(size(longY, 2), 1)];
            favar.variablestrings_exfactors = (favar.numpc+1:size(data_endo, 2))';
            favar.variablestrings_exfactors_index = [false(favar.numpc, 1); true(size(longY, 2), 1)];
            favar.data_exfactors = longY;
            [data_endo, favar] = bear.ogr_favar_gensample3(data_endo, favar);


            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = bear.olsvar(data_endo, longX, ...
                opt.const, opt.p);

            % set prior values
            [arvar] = bear.arloop(data_endo, opt.const, p, numEn);
            [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, numEn, numEx, p, ...
                numBRows, sizeB, opt.prior, priorexo);

            % obtain posterior distribution parameters
            [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, numEn, estimLength, numBRows);

            L = favar.L;
            FY = data_endo;
            %===============================================================================

            function sample = sampler()

                stationary=0;

                while stationary==0
                    B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, numBRows, numEn);
                    [stationary]=bear.checkstable(B(:), numEn, p, size(B, 1)); %switches stationary to 0, if the draw is not stationary
                end

                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma = bear.iwdraw(Sbar,alphabar);

                sample.beta = B(:);
                sample.sigma = sigma(:);
                sample.LX = LX(:);
                sample.FY = FY(:);
                sample.L = L(:);
                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%

    end

end

