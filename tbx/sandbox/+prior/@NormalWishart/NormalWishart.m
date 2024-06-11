
classdef NormalWishart < prior.Base

    methods
        function this = NormalWishart(varargin)
            this.Settings = prior.NormalWishart.Settings(varargin{:});
        end%

        function initialize(this, meta, YLX)
            arguments
                this
                meta (1, 1) model.ReducedForm.Meta
                YLX (1, 3) cell
            end
            this.Sampler = this.adapterForSampler(meta, YLX);
        end%
    end

end

