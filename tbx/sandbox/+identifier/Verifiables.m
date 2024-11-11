
classdef Verifiables < identifier.Base

    properties
        VerifiableTests identifier.VerifiableTests
        MaxCandidates (1, 1) double {mustBePositive} = Inf
        TryFlippingSign (1, 1) logical
    end


    methods
        function this = Verifiables(testStrings, options)
            arguments
                testStrings (1, :) string
                %
                options.MaxCandidates (1, 1) double = Inf
                options.TryFlippingSign (1, 1) logical = true
            end
            %
            this.Candidator = @identifier.candidateFromFactorUnconstrained;
            this.VerifiableTests = identifier.VerifiableTests(testStrings);
            this.MaxCandidates = options.MaxCandidates;
            this.TryFlippingSign = options.TryFlippingSign;
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            samplerR = modelS.ReducedForm.Estimator.Sampler;
            drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            candidator = @identifier.candidateFromFactorUnconstrained;
            vp = identifier.VerifiableProperties(modelS);
            vt = this.VerifiableTests;
            %
            function sample = samplerS()
                while true
                    sample = samplerR();
                    this.SampleCounter = this.SampleCounter + 1;

                    draw = drawer(sample);
                    sample.IdentificationDraw = draw;

                    % u = e*D or e = u/D
                    % Sigma = D'*D
                    Sigma = (draw.Sigma + draw.Sigma')/2;
                    P = chol(Sigma);

                    attemptCounter = 0;
                    while attemptCounter < this.MaxCandidates
                        sample.D = candidator(P);
                        attemptCounter = attemptCounter + 1;

                        this.CandidateCounter = this.CandidateCounter + 1;
                        vp.initialize4S(sample);
                        success = vt.evaluateShortCircuit(vp);
                        if success
                            return
                        end

                        if ~this.TryFlippingSign
                            continue
                        end

                        sample.D = -sample.D;
                        vp.initialize4S(sample);
                        success = vt.evaluateShortCircuit(vp);
                        if success
                            return
                        end
                    end
                end
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%
    end

end

