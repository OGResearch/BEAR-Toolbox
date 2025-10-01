
classdef ExactZeros ...
    < base.Identifier ...
    & base.identifier.InstantMixin

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


        function populateRestrictionMatrix(this, meta)
            arguments
                this
                meta (1, 1) base.Meta
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
                candidator = @(P) base.identifier.candidateFromFactorConstrained(P, R);
            else
                candidator = @base.identifier.candidateFromFactorUnconstrained;
            end
        end%


        function whenPairedWithModel(this, modelS)
            arguments
                this
                modelS (1, 1) base.Structural
            end
            this.checkTable(this.RestrictionTable, modelS.Meta);
        end%


        function beforeInitializeSampler(this, modelS)
            arguments
                this
                modelS (1, 1) base.Structural
            end
            this.checkTable(this.RestrictionTable, modelS.Meta);
            this.populateRestrictionMatrix(modelS.Meta);
        end%

    end


    methods
        function n = get.NumRestrictions(this)
            n = nnz(~isnan(this.RestrictionMatrix));
        end%
    end


    methods (Static)
        function checkTable(restrictionTable, meta)
            arguments
                restrictionTable (:, :) table
                meta (1, 1) base.Meta
            end
            if isempty(restrictionTable)
                return
            end
            %
            base.identifier.checkEndogenousAndShocksInTable(restrictionTable, meta);
            %
            % Table entries must be either 0 or NaN
            R = restrictionTable{:, :};
            if ~all(isnan(R(:)) | R(:) == 0)
                error("Exact zero restriction table entries must be either 0 or NaN.");
            end
            %
            % The # of exact zero restrictions is limited by the # of variables
            numVariables = size(R, 1);
            numRestrictions = nnz(R == 0);
            maxNumRestrictions = numVariables * (numVariables - 1) / 2 - 1;
            if numRestrictions > maxNumRestrictions
                error( ...
                    "Too many exact zero restrictions for the number of variables; max %g allowed." ...
                    , maxNumRestrictions ...
                );
            end
        end%
    end

end

