
classdef NormalDiffuse < estimator.Base

    methods
        function initializeSampler(this, longYXZ, dummiesYLX)
            %[
            arguments
                this
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = longYXZ{:};



            opt.priorsexogenous = this.Settings.Exogenous;
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
            sigmaAdapter.none = 41;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.bex  = this.Settings.BlockExogenous;

            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, ~, estimLength, numBRows, sizeB] = ...
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
            % arvar = bear.arloop(longY, opt.const, opt.p, numEn);
            arvar = bear.arloop(longY, opt.const, opt.p, numEn);

            %setting up prior
            [beta0, omega0] = bear.ndprior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, opt.lambda5, ...
                numEn, numEx, opt.p, numBRows, sizeB, opt.bex, blockexo, priorexo);

            invomega0 = diag(1./diag(omega0));
            B = Bhat;

            %===============================================================================

            this.SamplerCounter = uint64(0);

            function sampleStruct = sampler()
                % draw sigma from IW, conditional on beta from previous iteration
                % obtain first Shat, defined in (1.6.10)
                Shat = (Y - LX * B)' * (Y - LX * B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C' * C;

                % next draw from IW(Shat,estimLength)
                sigma = bear.iwdraw(Shat, estimLength);

                % Continue iteration by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
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
                betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * Y(:));

                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar),'lower') * mvnrnd(zeros(sizeB,1),eye(sizeB))';

                % update matrix B with each draw
                B = reshape(beta,size(B));

                sampleStruct.beta = beta;
                sampleStruct.sigma = sigma;
                this.SamplerCounter = this.SamplerCounter + 1;
            end

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

