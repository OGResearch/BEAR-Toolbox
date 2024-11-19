
classdef FlatFAVAROnestep < estimator.Base & estimator.PlainFAVARDrawersMixin

    properties
        DescriptionUX = "BFAVAR with Individual Normal-Wishart prior"

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

            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = true;
            [favar.l] = pca(longZ,'NumComponents', opt.numpc);

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

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = bear.olsvar(data_endo, longX, ...
                opt.const, opt.p);

            Bhat = (LX' * LX) \ (LX' * Y);
            EPS  = Y - LX * Bhat;
            B_ss = [Bhat' ; eye(numEn * (p - 1)) zeros(numEn * (p - 1), numEn)];
            sigma_ss = [(1 / estimLength) * (EPS' * EPS) zeros(numEn, numEn * (p - 1)); zeros(numEn * (p - 1), numEn * p)];

            XZ0mean = zeros(numEn * p, 1);
            XZ0var  = favar.L0*eye(numEn * p);
            XY      = favar.XY;
            L       = favar.L;
            Sigma   = bear.nspd(favar.Sigma);
            favar_X = longZ;
            nfactorvar = favar.nfactorvar;
            numpc   = favar.numpc;

            L0      = opt.L0*eye(numEn);

            %===============================================================================

            function sample = sampler()

                % Sample latent factors using Carter and Kohn (1994)
                FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, L, Sigma, B_ss, sigma_ss, indexnM);

                % demean generated factors
                FY = bear.favar_demean(FY);
                
                % Sample autoregressive coefficients B
                [B, ~, ~, LX, ~, Y, y] = bear.olsvar(FY, longX, opt.const, p);

                % Step 3: at iteration ii,  first draw sigma from IW,  conditional on beta from previous iteration
                % obtain first Shat,  defined in (1.6.10)
                Shat = (Y - LX * B)' * (Y - LX * B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C' * C;

                % next draw from IW(Shat, T)
                sigma = bear.iwdraw(Shat, T);

                sigma_ss(1:numEn, 1:numEn) = sigma;

                % step 4: with sigma drawn,  continue iteration ii by drawing beta from a multivariate Normal,  conditional on sigma obtained in current iteration
                % first invert sigma
                C = chol(bear.nspd(sigma));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix,  Uhlig05 prior
                invomegabar = kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following,  obtain betabar
                betabar = omegabar * (kron(invsigma, X') * y);

                % draw beta from N(betabar, omegabar);
                stationary = 0;
                while stationary ==  0
                    % draw from N(betabar, omegabar);
                    beta = betabar + chol(bear.nspd(omegabar), 'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1)); %switches stationary to 0,  if the draw is not stationary
                end


                % update matrix B with each draw
                Beta = reshape(beta, size(B));
                B_ss(1:numEn, :) = Beta';
                % Sample Sigma and L
                [Sigma, L] = bear.favar_SigmaL(Sigma, L, nfactorvar, numpc, true, numEn, favar_X, FY, opt.a0, opt.b0, ...
                    estimLength, p, L0);


                % update matrix B with each draw
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

