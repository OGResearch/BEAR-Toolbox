
classdef Ordinary < estimator.Base & estimator.PlainDrawersMixin

    methods (Static)
        function info = getModelReference()
            info.category = "basic_bvar";
        end
    end

    properties
        DescriptionUX = "Ordinary least squares VAR"

        CanHaveDummies = true
        
        HasCrossUnits = false

        Category = "Plain BVAR estimators"

        %Struct identification
        CanBeIdentified = true        
    end


    methods

        function initializeSampler(this, meta, longYX, dummiesYLX)
            %[

            arguments
                this
                meta (1, 1) base.Meta
                longYX (1, 2) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = longYX{:};


            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, ~, numBRows, ~] = bear.olsvar(longY, longX, opt.const, opt.p);
            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

            estimLength = size(Y, 1);

            %setting up prior
            [Bcap, ~, Scap, alphacap, phicap, alphatop] = bear.dopost(LX, Y, estimLength, numBRows, numEn);

            %===============================================================================

            function sample = sampler()

                B = bear.matrixtdraw(Bcap, Scap, phicap, alphatop, numBRows, numEn);

                % then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
                sigma = bear.iwdraw(Scap, alphacap);

                sample.beta = B(:);
                sample.sigma = sigma;

                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%

    end

end

