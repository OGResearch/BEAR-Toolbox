
classdef ...
    NormalWishartEstimator ...
    < reducedForm.AbstractEstimator

    methods
        function this = NormalWishartEstimator(varargin)
            this.PriorSettings = reducedForm.settings.NormalWishartPriorSettings(varargin{:});
        end%

        function initializeSampler(this, meta, YX)
            arguments
                this
                meta (1, 1) reducedForm.Meta
                YX (1, 2) cell
            end
            this.Sampler = this.adapterForSampler(meta, YX);
        end%
    end

end

