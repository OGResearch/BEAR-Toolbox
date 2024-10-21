
classdef Flat < estimator.Base

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

            opt.const = this.Settings.HasConstant;
            opt.p = this.Settings.Order;

            opt.bex  = this.Settings.BlockExogenous;

            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, estimLength, ~, sizeB] = ...
                bear.olsvar(Y_long, X_long, opt.const, opt.p);

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
                invomegabar = kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following, obtain betabar
                betabar = omegabar * (kron(invsigma, LX') * Y(:));

                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar),'lower') * mvnrnd(zeros(sizeB,1),eye(sizeB))';

                sampleStruct.beta = beta;
                sampleStruct.sigma = sigma;
                this.SamplerCounter = this.SamplerCounter + 1;
            end

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

