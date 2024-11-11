
classdef Cholesky < identifier.Base

    methods
        function this = Cholesky(varargin)
            this.Candidator = @(P) P;
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            horizon = modelS.Meta.IdentificationHorizon;
            samplerR = modelS.ReducedForm.Estimator.Sampler;
            drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            candidator = this.Candidator;
            %
            function sample = samplerS()
                this.SampleCounter = this.SampleCounter + 1;
                sample = samplerR();
                draw = drawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                sample.IdentificationDraw = draw;
                Sigma = (draw.Sigma + draw.Sigma')/2;
                P = chol(Sigma);
                sample.D = candidator(P);
                this.CandidateCounter = this.CandidateCounter + 1;
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%
    end

end

