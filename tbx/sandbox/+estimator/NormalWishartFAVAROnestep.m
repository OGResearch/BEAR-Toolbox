
classdef NormalWishartFAVAROnestep < estimator.Base & estimator.PlainFAVARDrawersMixin

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
                meta (1, 1) model.Meta
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, longZ] = longYXZ{:};

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

            opt.L0 = this.Settings.LoadingVariance;
            opt.a0 = this.Settings.SigmaShape;
            opt.b0 = this.Settings.SigmaScale;

            opt.numpc = meta.NumFactors;

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;

            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = true;
            [favar.l] =pca(longZ,'NumComponents',opt.numpc);

            favar.numpc = opt.numpc;
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

            indexnM = repmat(favar.variablestrings_factorsonly_index, 1, opt.p);
            indexnM = find(indexnM==1);

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = bear.olsvar(data_endo, longX, opt.const, opt.p);

            Bhat = (LX' * LX) \ (LX' * Y);
            EPS  = Y - LX * Bhat;
            B_ss = [Bhat' ; eye(numEn * (p - 1)) zeros(numEn * (p - 1), numEn)];
            sigma_ss = [(1 / estimLength) * (EPS' * EPS) zeros(numEn, numEn * (p - 1)); zeros(numEn * (p - 1), numEn * p)];

            XZ0mean          = zeros(numEn * p,1);
            XZ0var           = favar.L0*eye(numEn * p);
            XY               = favar.XY;
            L                = favar.L;
            Sigma            = bear.nspd(favar.Sigma);
            favar_X          = longZ;
            nfactorvar       = favar.nfactorvar;
            numpc            = favar.numpc;

            L0               = opt.L0*eye(numEn);
            %===============================================================================

            function sample = sampler()

                % Sample latent factors using Carter and Kohn (1994)
                FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, L, Sigma, B_ss, sigma_ss, indexnM);

                % demean generated factors
                FY = bear.favar_demean(FY);

                % Sample autoregressive coefficients B
                temp = bear.lagx(FY, p);
                Y = temp(:, 1:numEn);

                %variance from univariate OLS for priors
                arvar = bear.arloop(FY, opt.const, p, numEn);

                % set prior values, new with every iteration for onestep only
                [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4,...
                    numEn, numEx, p, numBRows, sizeB, opt.prior, priorexo);

                % obtain posterior distribution parameters, new with every iteration for onestep only
                [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y,...
                    numEn, estimLength, numBRows);


                % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
                stationary = 0;

                while stationary == 0

                    B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, numBRows, numEn);
                    [stationary] = bear.checkstable(B(:), numEn, p, size(B, 1)); %switches stationary to 0, if the draw is not stationary

                end

                B_ss(1:numEn, :) = B';

                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma = bear.iwdraw(Sbar, alphabar);

                sigma_ss(1:numEn, 1:numEn) = sigma;

                % Sample Sigma and L
                [Sigma, L] = bear.favar_SigmaL(Sigma, L, nfactorvar, numpc, true, numEn, favar_X, ...
                    FY, opt.a0, opt.b0, estimLength, p, L0);

                sample.beta = B(:);
                sample.sigma = sigma;
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

