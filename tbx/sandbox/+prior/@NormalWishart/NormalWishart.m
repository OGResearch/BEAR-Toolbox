
classdef NormalWishart < prior.Base

    methods
        function this = NormalWishart(varargin)
            this.Settings = prior.NormalWishart.Settings(varargin{:});
        end%

        function initializeSampler(this, YLX)
            arguments
                this
                YLX (1, 3) cell
            end
            %
            this.Sampler = this.adapterForSampler(YLX);
        end%
    end

end

