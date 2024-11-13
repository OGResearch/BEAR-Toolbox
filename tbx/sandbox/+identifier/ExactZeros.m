
classdef ExactZeros < identifier.Base

    properties
        RestrictionTable
    end


    properties (Dependent)
        NumRestrictions
    end


    methods
        function this = ExactZeros(restrictionTable)
            arguments
                restrictionTable = []
            end
            this.RestrictionTable = restrictionTable;
        end%

        function checkConsistency(this, modelS)
            if isempty(this.RestrictionTable)
                return
            end
            meta = modelS.Meta;
            tablex.checkConsistency(this.RestrictionTable);
            modelEndogenousNames = textual.stringify(meta.EndogenousNames);
            modelShockNames = textual.stringify(meta.ShockNames);
            tableEndogenousNames = textual.stringify(this.RestrictionTable.Properties.RowNames);
            tableShockNames = textual.stringify(this.RestrictionTable.Properties.VariableNames);
            if modelEndogenousNames ~= tableEndogenousNames
                error("Endogenous names in the model and the restriction table must match.");
            end
            if modelShockNames ~= tableShockNames
                error("Shock names in the model and the restriction table must match.");
            end
        end%

        function R = getRestrictionMatrix(this)
            if isempty(this.RestrictionTable)
                R = [];
                return
            end
            endogenousNames = textual.stringify(this.RestrictionTable.Properties.RowNames);
            shockNames = textual.stringify(this.RestrictionTable.Properties.VariableNames);
            R = this.RestrictionTable{endogenousNames, shockNames};
            %
            % Transpose the restriction matrix so that the rows correspond to
            % shocks and columns to endogenous variables; this is consistent
            % with the row-oriented VAR system representation in BEAR
            R = transpose(R);
        end%

        function candidator = getCandidator(this)
            %[
            if this.NumRestrictions > 0
                R = this.getRestrictionMatrix();
                candidator = @(P) identifier.candidateFromFactorConstrained(P, R);
            else
                candidator = @identifier.candidateFromFactorUnconstrained;
            end
            %]
        end%

        function initializeSampler(this, modelS)
            if ~isempty(this.RestrictionTable)
                this.checkConsistency(modelS);
            end
            samplerR = modelS.ReducedForm.Estimator.Sampler;
            drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            candidator = this.getCandidator();
            %
            function sample = samplerS()
                sample = samplerR();
                this.SampleCounter = this.SampleCounter + 1;
                draw = drawer(sample);
                sample.IdentificationDraw = draw;
                Sigma = (draw.Sigma + draw.Sigma')/2;
                P = chol(Sigma);
                sample.D = candidator(P);
                this.CandidateCounter = this.CandidateCounter + 1;
                %
            end%
            %
            this.Sampler = @samplerS;
        end%
    end


    methods
        function n = get.NumRestrictions(this)
            n = nnz(~isnan(this.getRestrictionMatrix()));
        end%
    end

end

