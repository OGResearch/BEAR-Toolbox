
classdef FlatFAVARTwostep < estimator.Base & estimator.PlainFAVARDrawersMixin
%FAVAR version of prior =41 within lambda> 999 BEAR5
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
                meta (1, 1) model.Meta
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, longZ] = longYXZ{:};

            opt.bex = this.Settings.BlockExogenous;

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            %% FAVAR settings, maybe we can move this to a separate function

            favar.onestep = false;
            favar.numpc = meta.NumFactors;            
            [FY, favar] = estimator.initializeFAVAR(longY, longZ, favar, opt.p);


            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            % set initial values for B (step 2); use OLS estimates
            B = Bhat;

            LD = favar.L;
            
            %===============================================================================

            function sample = sampler()

                % Step 3: at iteration ii,  first draw sigma from IW,  conditional on beta from previous iteration
                % obtain first Shat,  defined in (1.6.10)
                Shat = (Y - LX * B)' * (Y - LX * B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C' * C;

                % next draw from IW(Shat, estimLength)
                sigma = bear.iwdraw(Shat, estimLength);

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
                betabar = omegabar * (kron(invsigma, LX') * Y(:));

                % draw beta from N(betabar, omegabar);
                stationary = 0;
                while stationary  ==  0
                    % draw from N(betabar, omegabar);
                    beta = betabar + chol(bear.nspd(omegabar), 'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1)); %switches stationary to 0,  if the draw is not stationary
                end

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
