
classdef ExactZeros < identifier.Base & identifier.InstantMixin

    properties
        RestrictionTable
        RestrictionMatrix (:, :) double
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

        function checkRestrictionTableConsistency(this, meta)
            if isempty(this.RestrictionTable)
                return
            end
            compareLists = @isequal;
            tablex.checkConsistency(this.RestrictionTable);
            tableEndogenousHeadings = textual.stringify(this.RestrictionTable.Properties.RowNames);
            tableShockHeadings = textual.stringify(this.RestrictionTable.Properties.VariableNames);
            if ~compareLists(this.SeparableEndogenousNames, tableEndogenousHeadings)
                error("Row names in the restriction table must match endogenous names in the model.");
            end
            if ~compareLists(this.SeparableShockNames, tableShockHeadings)
                error("Column names in the restriction table must match shock names in the model.");
            end
        end%

        function populateRestrictionMatrix(this, meta)
            arguments
                this
                meta (1, 1) model.Meta
            end
            this.RestrictionMatrix = double.empty(0, 0);
            if isempty(this.RestrictionTable)
                return
            end
            R = this.RestrictionTable{this.SeparableEndogenousNames, this.SeparableShockNames};
            %
            % Transpose the restriction matrix so that the rows correspond to
            % shocks and columns to endogenous variables; this is consistent
            % with the row-oriented VAR system representation in BEAR
            this.RestrictionMatrix = transpose(R);
        end%

        function choleskator = getCholeskator(this)
            choleskator = @chol;
        end%

        function candidator = getCandidator(this)
            if this.NumRestrictions > 0
                R = this.RestrictionMatrix;
                candidator = @(P) identifier.candidateFromFactorConstrained(P, R);
            else
                candidator = @identifier.candidateFromFactorUnconstrained;
            end
        end%

        function beforeInitializeSampler(this, modelS)
            arguments
                this
                modelS (1, 1) model.Structural
            end
            meta = modelS.Meta;
            this.checkRestrictionTableConsistency(meta);
            this.populateRestrictionMatrix(meta);
        end%

        % function initializeSampler(this, modelS)
        %     arguments
        %         this
        %         modelS (1, 1) model.Structural
        %     end
        %     %
        %     meta = modelS.Meta;
        %     estimator = modelS.ReducedForm.Estimator;
        %     numUnits = meta.NumUnits;
        %     hasCrossUnitVariationInSigma = estimator.HasCrossUnitVariationInSigma;
        %     sampler = estimator.Sampler;
        %     drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
        %     candidator = this.getCandidator();
        %     choleskator = this.getCholeskator();
        %     %
        %     function sample = samplerS()
        %         sample = sampler();
        %         this.SampleCounter = this.SampleCounter + 1;
        %         draw = drawer(sample);
        %         sample.IdentificationDraw = draw;
        %         Sigma = identifier.makeSymmetric(draw.Sigma);
        %         P = choleskator(Sigma);
        %         D = candidator(P);
        %         sample.D = D;
        %         this.CandidateCounter = this.CandidateCounter + 1;
        %         %
        %     end%
        %     %
        %     this.Sampler = @samplerS;
        % end%
    end


    methods
        function n = get.NumRestrictions(this)
            n = nnz(~isnan(this.RestrictionMatrix));
        end%
    end

end

