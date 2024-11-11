
classdef MinnesotaFAVARTwostep < estimator.Base

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

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;
            opt.numpc = this.Settings.NumFactors;

            sigmaAdapter = struct();
            sigmaAdapter.diag = 12;
            sigmaAdapter.ar = 11;
            sigmaAdapter.full = 13;
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

            [Bhat, ~, ~, LX, ~, ~, y, EPS, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
                bear.olsvar(data_endo, longX, opt.const, opt.p);
            sigmahat = (1 / estimLength) * (EPS' * EPS);

            [arvar] = bear.arloop(data_endo, opt.const, p, numEn);

            [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, numEn, numEx, p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);

            % obtain posterior distribution parameters
            [betabar, omegabar] = bear.mpost(beta0, omega0, sigma, LX, y, sizeB, numEn);

            L = favar.L;
            B = Bhat;
            FY = data_endo;
            %===============================================================================

            function sample = sampler()

                % draw beta from N(betabar,omegabar);
                stationary = 0;
                while stationary==0
                    beta = betabar + chol(bear.nspd(omegabar), 'lower')*mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1) ); %switches stationary to 0, if the draw is not stationary
                end

                sample.beta = beta;
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

