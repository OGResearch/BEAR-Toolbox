
classdef Custom < identifier.Base

    properties
        Exact (1, :) identifier.custom.Exact
        Verifiable (1, :) identifier.custom.Verifiable
    end

    methods
        function this = Custom(varargin)
            this = this@identifier.Base(varargin{:});
            %
            this.Exact = identifier.custom.Exact.empty(1, 0);
            for exactString = reshape(string(this.Settings.Exact), 1, [])
                this.Exact(end+1) = identifier.custom.Exact(exactString);
            end
            %
            this.Verifiable = identifier.custom.Verifiable.empty(1, 0);
            for verifiableString = reshape(string(this.Settings.Verifiable), 1, [])
                this.Verifiable(end+1) = identifier.custom.Verifiable(verifiableString);
            end
        end%

        function stateExacts = evalExacts(this, model, dataYLX)
            stateExacts = this.initializeExacts(model, dataYLX);
            for e = this.Exact
                stateExacts = e.Callable(stateExacts);
            end
        end%

        function stateExacts = initializeExacts(this, model, dataYLX)
            stateExacts = struct();
            redModel = model.ReducedForm;
            stateExacts.EndogenousNames = names.createDictionary(redModel.Meta.EndogenousNames);
            stateExacts.ShockNames = names.createDictionary(model.Meta.ShockNames);
        end%

        function state = initializeVerifiables(this, model, dataYLX, structuralSystem)
            state = identifier.custom.State();
            state.addprop("EndogenousNames");
            state.EndogenousNames = names.createDictionary(model.ReducedForm.Meta.EndogenousNames);
            state.addprop("ShockNames");
            state.ShockNames = names.createDictionary(model.Meta.ShockNames);
            state.addprop("System");
            state.System = structuralSystem;
        end%

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
            stateExacts = this.evalExacts(model, dataYLX);
            instantZero = [];
            if isfield(stateExacts, "InstantZero")
                instantZero = stateExacts.InstantZero;
            end
            %
            function [strSample, redSample, info] = sampler()
                [redSystem, redSample] = redSystemSampler();
                [A, C, Sigma] = redSystem{:};
                P = chol(Sigma, "lower");
                numCandidates = 0;
                while true
                    Q = system.randomConstrainedOrthonormal(P, instantZero);
                    numCandidates = numCandidates + 1;
                    D = P * Q;
                    structuralSystem = [redSystem, {D, stdVec}];
                    state = this.initializeVerifiables(model, dataYLX, structuralSystem);
                    lastFlag = true;
                    for v = this.Verifiable
                        lastFlag = v.Callable(state);
                        if ~lastFlag
                            break
                        end
                    end
                    if lastFlag
                        break
                    end
                end
                % u = e*D
                % Sigma = D'*D
                strSample = {reshape(D, 1, 1, []), };
                this.SampleCounter = this.SampleCounter + 1;
                info = this.SAMPLER_INFO;
                info.NumCandidates = numCandidates;
            end%
            %
            this.Sampler = @sampler;
        end%
    end

end

