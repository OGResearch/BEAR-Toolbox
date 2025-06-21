
classdef FlatFAVAROnestep < estimator.Base & estimator.PlainFAVARDrawersMixin
%% BFAVAR with flat prior and one-step estimation
% FAVAR with prior = 41 in BEAR5 with lambda1>999
    
    methods (Static)
        function info = getModelReference()
            info.category = "favar";
        end
    end

    properties
        DescriptionUX = "BFAVAR with Individual Normal-Wishart prior"

        CanHaveDummies = false
        
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

            opt.L0 = this.Settings.LoadingVariance;
            opt.a0 = this.Settings.SigmaShape;
            opt.b0 = this.Settings.SigmaScale;


            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = true;
            [FY, favar, indexnM] = estimator.initializeFAVAR(longY, longZ, favar, opt.p, meta);

            [Bhat, ~, ~, LX, ~, Y, ~, EPS, ~, numEn, ~, p, estimLength, ~, sizeB] = bear.olsvar(FY, longX, ...
                opt.const, opt.p);
            
            B_ss = [Bhat' ; eye(numEn * (p - 1)) zeros(numEn * (p - 1), numEn)];
            sigma_ss = [(1 / estimLength) * (EPS' * EPS) zeros(numEn, numEn * (p - 1)); zeros(numEn * (p - 1), numEn * p)];

            XZ0mean = zeros(numEn * p, 1);
            XZ0var  = opt.L0*eye(numEn * p);
            XY      = favar.XY;
            LD = favar.L;
            Sigma   = bear.nspd(favar.Sigma);
            favar_X = longZ;
            nfactorvar = favar.nfactorvar;
            numpc   = favar.numpc;

            L0      = opt.L0*eye(numEn);

            %===============================================================================

            function sample = sampler()

                % Sample latent factors using Carter and Kohn (1994)
                FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, LD, Sigma, B_ss, sigma_ss, indexnM);

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
                sigma = bear.iwdraw(Shat, estimLength);

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
                betabar = omegabar * (kron(invsigma, LX') * y);

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
                [Sigma, LD] = bear.favar_SigmaL(Sigma, LD, nfactorvar, numpc, true, numEn, favar_X, FY, opt.a0, opt.b0, ...
                    estimLength, p, L0);


                % update matrix B with each draw
                sample.beta = beta;
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

