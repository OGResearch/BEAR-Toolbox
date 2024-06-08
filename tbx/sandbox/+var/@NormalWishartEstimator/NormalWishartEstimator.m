
classdef ...
    NormalWishartEstimator ...
    < var.AbstractEstimator

    methods
        function this = NormalWishartEstimator(varargin)
            this.PriorSettings = var.settings.NormalWishartPriorSettings(varargin{:});
        end%

        function initializeSampler(this, meta, YX)
            arguments
                this
                meta (1, 1) var.Meta
                YX (1, 2) cell
            end
            this.Sampler = this.adapterForSampler(meta, YX);
        end%
    end

end

