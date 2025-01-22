
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
            tablex.checkConsistency(this.RestrictionTable);
            %
            meta = modelS.Meta;
            hasCrossUnits = meta.HasCrossUnits;
            %
            % TODO: Refactor
            if ~hasCrossUnits
                modelEndogenousHeadings = textual.stringify(meta.EndogenousConcepts);
                modelShockHeadings = textual.stringify(meta.ShockConcepts);
            else
                modelEndogenousHeadings = textual.stringify(meta.EndogenousNames);
                modelShockHeadings = textual.stringify(meta.ShockNames);
            else
            %
            tableEndogenousHeadings = textual.stringify(this.RestrictionTable.Properties.RowNames);
            tableShockHeadings = textual.stringify(this.RestrictionTable.Properties.VariableNames);
            if modelEndogenousHeadings ~= tableEndogenousHeadings || modelShockHeadings ~= tableShockHeadings
                error("Row names and variable names in the restriction table must match the model.");
            end
        end%

        function R = getRestrictionMatrix(this)
            if isempty(this.RestrictionTable)
                R = [];
                return
            end
            meta = modelS.Meta;
            estimator = modelS.ReducedForm.Estimator;
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

        function choleskator = getCholeskator(this)
            choleskator = @chol;
        end%

        function initializeSampler(this, modelS)
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            if ~isempty(this.RestrictionTable)
                this.checkConsistency(modelS);
            end
            meta = modelS.Meta;
            estimator = modelS.ReducedForm.Estimator;
            numUnits = meta.NumUnits;
            hasCrossUnitVariationInSigma = estimator.HasCrossUnitVariationInSigma;
            samplerR = estimator.Sampler;
            drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            candidator = this.getCandidator();
            choleskator = this.getCholeskator();
            %
            function sample = samplerS()
                sample = samplerR();
                this.SampleCounter = this.SampleCounter + 1;
                draw = drawer(sample);
                sample.IdentificationDraw = draw;
                Sigma = identifier.makeSymmetric(draw.Sigma);
                P = choleskator(Sigma);
                D = candidator(P);
                sample.D = D;
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

