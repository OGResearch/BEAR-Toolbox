
classdef Ordinary < estimator.Plain

    properties
        CanHaveDummies = true
        CanHaveReducibles = false
        HasCrossUnits = false
    end


    methods

        function initializeSampler(this, meta, longYXZ, dummiesYLX)
            %[

            arguments
                this
                meta
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = longYXZ{:};


            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, ~, numBRows, ~] = bear.olsvar(longY, longX, opt.const, opt.p);
            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

            estimLength = size(Y, 1);

            %setting up prior
            [Bcap, ~, Scap, alphacap, phicap, alphatop] = bear.dopost(LX, Y, estimLength, numBRows, numEn);

            %===============================================================================

            function sampleStruct = sampler()

                B = bear.matrixtdraw(Bcap, Scap, phicap, alphatop, numBRows, numEn);

                % then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
                sigma = bear.iwdraw(Scap, alphacap);

                sampleStruct.beta = B(:);
                sampleStruct.sigma = sigma;

                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%

    end

end

