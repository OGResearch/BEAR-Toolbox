
classdef Ordinary < estimator.Base

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


            opt.const = meta.HasIntercept;
            opt.p = meta.Order;
            
            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, ~, numBRows, ~] = bear.olsvar(Y_long, X_long, opt.const, opt.p);

            %setting up prior
            [Bcap, ~, Scap, alphacap, phicap, alphatop] = bear.dopost(LX, Y, estimLength, numBRows, numEn);

            %===============================================================================

            this.SamplerCounter = uint64(0);

            function sampleStruct = sampler()

                B = bear.matrixtdraw(Bcap, Scap, phicap, alphatop, numBRows, numEn);

                % then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
                sigma = bear.iwdraw(Scap, alphacap);

                sampleStruct.beta = B(:);
                sampleStruct.sigma = sigma(:);

                this.SamplerCounter = this.SamplerCounter + 1;
                
            end%

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

