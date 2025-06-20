
classdef Flat < estimator.Base & estimator.PlainDrawersMixin
%% BVAR with flat prior
% prior = 41 in BEAR5 with lambda1>999
    
    methods (Static)
        function info = getModelReference()
            info.category = "basic_bvar";
        end
    end

    properties
        DescriptionUX = "BVAR with flat prior"

        Category = "Plain BVAR estimators"

        CanHaveDummies = true
        
        HasCrossUnits = false

        %Struct identification
        CanBeIdentified = true
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




            [longY, longX, ~] = longYXZ{:};



            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.bex  = this.Settings.BlockExogenous;

            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, ~, ~, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            B = Bhat;

            estimLength = size(Y, 1);
            %===============================================================================

            function sample = sampler()
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
                beta = betabar + chol(bear.nspd(omegabar),'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';

                sample.beta = beta;
                sample.sigma = sigma;
                this.SampleCounter = this.SampleCounter + 1;
            end

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

