
classdef NormalDiffuseFAVARTwostep < estimator.Base

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

            opt.bex = this.Settings.BlockExogenous;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

            opt.numpc = this.Settings.NumFactors;

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end


            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = false;
            favar.numpc = opt.numpc;
            [favar.l] =pca(longZ, 'NumComponents', opt.numpc);

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

            [Bhat, ~, ~, LX, ~, Y, y, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = bear.olsvar(data_endo, longX, ...
                opt.const, opt.p);

            [arvar] = bear.arloop(data_endo, opt.const, p, numEn);

            % set prior values
            [beta0, omega0] = bear.ndprior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, opt.lambda5, ...
                numEn, numEx, p, numBRows, sizeB, opt.bex, blockexo, priorexo);

            % invert omega0, as it will be used repeatedly
            invomega0 = diag(1 ./ diag(omega0));

            L = favar.L;
            B = Bhat;
            FY = data_endo;
            %===============================================================================

            function sample = sampler()

                % Step 3: at iteration ii, first draw sigma from IW, conditional on beta from previous iteration
                % obtain first Shat, defined in (1.6.10)
                Shat = (Y - LX * B)'*(Y - LX * B);

                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C'*C;

                sigma = bear.iwdraw(Shat, estimLength);

                % step 4: with sigma drawn, continue iteration ii by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
                % first invert sigma
                C = chol(bear.nspd(sigma));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following, obtain betabar
                betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * y);

                % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
                stationary = 0;

                while stationary == 0
                    beta = betabar + chol(bear.nspd(omegabar), 'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1)); %switches stationary to 0, if the draw is not stationary
                end

                % update matrix B with each draw
                B = reshape(beta, size(B));
   
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
