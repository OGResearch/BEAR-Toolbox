
classdef Cholesky < identifier.Base

    methods

        function initializeSampler(this, meta, modelR)
            %[
            arguments
                this
                meta (1, 1) meta.Structural
                modelR (1, 1) model.ReducedForm
            end
            %
            horizon = meta.IdentificationHorizon;
            samplerR = modelR.Estimator.Sampler;
            drawerR = @(sample) modelR.Estimator.IdentificationDrawer(sample, horizon);
            %
            function sample = sampler()
                sample = samplerR();
                draw = drawerR(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                Sigma = (draw.Sigma + draw.Sigma')/2;
                sample.D = chol(Sigma);
                sample.IdentificationDraw = draw;
                this.SampleCounter = this.SampleCounter + 1;
            end%
            %
            this.Sampler = @sampler;
            %]
        end%

    end

end

