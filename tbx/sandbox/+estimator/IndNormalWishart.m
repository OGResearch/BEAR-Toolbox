
classdef IndNormalWishart < estimator.Base

    methods
        function initializeSampler(this, longYXZ, dummiesYLX)
            %[
            arguments
                this
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = YXZ{:};

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
        %         opt.lambda4 = repmat(opt.lambda4, numEn, numEx);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.eye = 32;
            sigmaAdapter.ar = 31;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = this.Settings.HasConstant;
            opt.p = this.Settings.Order;

            [Bhat, ~, ~, LX, ~, Y, y, ~, ~, numEn, numEx, ~, estimLength, numBRows, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

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
            arvar = bear.arloop(longY, opt.const, opt.p, numEn);

            %setting up prior
            [beta0, omega0, S0, alpha0] = bear.inwprior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, numEn, numEx, opt.p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);


            % invert omega0, as it will be used repeatedly during step 4
            invomega0 = diag(1 ./ diag(omega0));

            % set initial values for B (step 2); use OLS estimates
            B = Bhat;

            % set the value of alphahat, defined in (1.5.16)
            alphahat = estimLength + alpha0;


            %===============================================================================

            this.SamplerCounter = uint64(0);

            function sampleStruct = sampler()

                % Step 3: at iteration ii, first draw sigma from IW, conditional on beta from previous iteration
                % obtain first Shat, defined in (1.5.15)
                Shat = (Y - LX * B)' * (Y - LX * B) + S0;

                % Correct potential asymmetries due to rounding errors from Matlab
                Shat = bear.nspd(Shat);

                % next draw from IW(Shat,alphahat)
                sigma = bear.iwdraw(Shat, alphahat);

                % step 4: with sigma drawn, continue iteration ii by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
                % first invert sigma
                C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following, obtain betabar
                % betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * y);
                betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * Y(:));

                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(sizeB, 1);

                % update matrix B with each draw
                B = reshape(beta, size(B));

                sampleStruct.beta = beta;
                sampleStruct.sigma = sigma;
                this.SamplerCounter = this.SamplerCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

