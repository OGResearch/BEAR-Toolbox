
classdef Triangular < identification.Base

    methods
        function this = Triangular(varargin)
            this.Settings = identification.Triangular.Settings(varargin{:});
        end%

        function outSampler = initializeSampler(this, redModel, YLX)
            this.SamplerCounter = uint64(0);
            redSystemSampler = redModel.getSystemSampler();
            %
            function [strSample, redSample] = sampler()
                [redSystem, redSample] = redSystemSampler();
                [A, C, Sigma] = redSystem{:};
                % u = e*D
                % Sigma = D'*D
                % D 
                D = chol(Sigma);
                strSample = {reshape(D, 1, 1, [])};
                this.SamplerCounter = this.SamplerCounter + 1;
            end%
            %
            this.Sampler = @sampler;
        end%
    end

end

