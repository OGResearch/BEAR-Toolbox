
classdef Triangular < identifier.Base

    methods
        function outSampler = initializeSampler(this, model, dataYLX)
            arguments
                this
                model (1, 1) model.Structural
                dataYLX (1, 3) cell
            end
            %
            redModel = model.ReducedForm;
            redSystemSampler = redModel.getSystemSampler();
            stdVec = this.StdVec;
            %
            function [strSample, redSample, info] = sampler()
                [redSystem, redSample] = redSystemSampler();
                [A, C, Sigma] = redSystem{:};
                % u = e*D or e = u/D
                % Sigma = D'*D
                D = chol(Sigma);
                numE = size(D, 1);
                stdVec = ones(1, numE);
                strSample = {reshape(D, 1, 1, []), };
                this.SamplerCounter = this.SamplerCounter + 1;
                info = this.SAMPLER_INFO;
                info.NumCandidates = 1;
            end%
            %
            this.Sampler = @sampler;
        end%
    end

end

