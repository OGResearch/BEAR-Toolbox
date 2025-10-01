
classdef Custom ...
    < base.Identifier

    properties
        Exact (1, :) base.identifier.custom.Exact
        Verifiable (1, :) base.identifier.custom.Verifiable
    end

    methods
        function this = Custom(varargin)
            this = this@base.Identifier(varargin{:});
            %
            this.Exact = base.identifier.custom.Exact.empty(1, 0);
            for exactString = reshape(string(this.Settings.Exact), 1, [])
                this.Exact(end+1) = base.identifier.custom.Exact(exactString);
            end
            %
            this.Verifiable = base.identifier.custom.Verifiable.empty(1, 0);
            for verifiableString = reshape(string(this.Settings.Verifiable), 1, [])
                this.Verifiable(end+1) = base.identifier.custom.Verifiable(verifiableString);
            end
        end%

        function stateExacts = evalExacts(this, model, dataYLX)
            stateExacts = this.initializeExacts(model, dataYLX);
            for e = this.Exact
                stateExacts = e.Callable(stateExacts);
            end
        end%

        function stateExacts = initializeExacts(this, modelS, dataYLX)
            stateExacts = struct();
            metaR = modelS.ReducedForm.Meta;
            stateExacts.EndogenousNames = textual.createDictionary(metaR.EndogenousNames);
            stateExacts.ShockNames = textual.createDictionary(metaR.ShockNames);
        end%

        function state = initializeVerifiables(this, modelS, dataYLX, structuralSystem)
            metaR = modelS.ReducedForm.Meta;
            metaS = modelS.Meta;
            state = base.identifier.custom.State();
            state.addprop("EndogenousNames");
            state.EndogenousNames = textual.createDictionary(metaR.EndogenousNames);
            state.addprop("ShockNames");
            state.ShockNames = textual.createDictionary(metaS.ShockNames);
            state.addprop("System");
            state.System = structuralSystem;
        end%
    end

end

