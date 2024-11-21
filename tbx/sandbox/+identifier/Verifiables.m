
classdef Verifiables < identifier.Base

    properties (Constant)
        DEFAULT_MAX_CANDIDATES = 100
        DEFAULT_FLIP_SIGN = true
    end


    properties
        ExactZeros (1, 1) identifier.ExactZeros
        VerifiableTests identifier.VerifiableTests
        MaxCandidates (1, 1) double {mustBePositive} = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
        FlipSign (1, 1) logical = identifier.Verifiables.DEFAULT_FLIP_SIGN
        EvaluateMethod (1, 1) string
    end


    methods
        function this = Verifiables(tests, options)
            arguments
                tests
                %
                options.ExactZeros (1, 1) identifier.ExactZeros = identifier.ExactZeros()
                options.MaxCandidates (1, 1) double = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.FlipSign (1, 1) logical = identifier.Verifiables.DEFAULT_FLIP_SIGN
                options.ShortCircuit (1, 1) logical = true
            end
            %
            if istable(tests)
                tests = tablex.toVerifiables(tests);
            end
            tests = textual.stringify(tests);
            this.ExactZeros = options.ExactZeros;
            this.VerifiableTests = identifier.VerifiableTests(tests);
            this.MaxCandidates = options.MaxCandidates;
            this.FlipSign = options.FlipSign;
            if options.ShortCircuit
                this.EvaluateMethod = "evaluateShortCircuit";
            else
                this.EvaluateMethod = "evaluateAll";
            end
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
            % candidator = @identifier.candidateFromFactorUnconstrained;
            candidator = this.ExactZeros.getCandidator();
            vp = identifier.VerifiableProperties(modelS);
            vt = this.VerifiableTests;
            method = this.EvaluateMethod;
            %
            function sample = samplerS()
                tracker = [];
                while true
                    sample = samplerR();
                    this.SampleCounter = this.SampleCounter + 1;
                    %
                    draw = drawer(sample);
                    sample.IdentificationDraw = draw;
                    %
                    % u = e*D or e = u/D
                    % Sigma = D'*D
                    Sigma = (draw.Sigma + draw.Sigma')/2;
                    P = chol(Sigma);
                    %
                    attemptCounter = 0;
                    while attemptCounter < this.MaxCandidates
                        sample.D = candidator(P);
                        disp(sample.D)
                        attemptCounter = attemptCounter + 1;
                        %
                        this.CandidateCounter = this.CandidateCounter + 1;
                        vp.initialize4S(sample);
                        success = vt.(method)(vp);
                        if all(success)
                            tracker = [tracker, success];
                            sample.Tracker = tracker;
                            return
                        end
                        %
                        if ~this.FlipSign
                            continue
                        end
                        %
                        sample.D = -sample.D;
                        vp.initialize4S(sample);
                        success = vt.(method)(vp);
                        if all(success)
                            tracker = [tracker, success];
                            sample.Tracker = tracker;
                            return
                        end
                        tracker = [tracker, success];
                    end
                end
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%
    end

end

