
classdef Meta ...
    < base.Meta

    % % Reduced-form model meta information
    % properties (SetAccess=protected)
    %     % Endogenous concepts; the entire names will be created
    %     % by prepending unit names to endogenous concepts
    %     EndogenousConcepts (1, :) string

    %     % Names of units in panel models
    %     Units (1, :) string = string.empty(1, 0)

    %     % Names of exogenous variables
    %     ExogenousNames (1, :) string %Names of exogenous variables

    %     % Prefix prepended to residual names
    %     ResidualPrefix (1, 1) string = "resid"

    %     % Autoregressive order of the VAR model
    %     Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1

    %     % True if the model includes an intercept (constant) term
    %     HasIntercept (1, 1) logical

    %     % Span of fitted data
    %     ShortSpan
    % end


    % % Structural model meta information
    % properties (SetAccess=protected)
    %     % Names of structural shock concepts; the entire names
    %     % will be created by prepending unit names to shock concepts
    %     ShockConcepts (1, :) string = string.empty(1, 0)

    %     % Number of periods for which the VMA
    %     % representation (shock response matrices) will be drawn
    %     IdentificationHorizon (1, 1) double = NaN
    % end


    % properties (Constant)
    %     SEPARATOR = "_"
    % end


    % properties (Dependent)
    %     ShortStart
    %     ShortEnd
    %     %
    %     EndogenousNames
    %     HasExogenous
    %     ShockNames
    %     %
    %     NumEndogenousNames
    %     NumExogenousNames
    %     NumEndogenousConcepts
    %     NumResiduals
    %     NumShockConcepts
    %     NumShocks
    %     NumShockNames
    %     %
    %     EstimationSpan
    %     EstimationStart
    %     EstimationEnd
    %     InitSpan
    %     InitStart
    %     InitEnd
    %     LongStart
    %     LongEnd
    %     LongSpan
    %     NumShortSpan
    % end


    methods
        function update(this, options)
            arguments
                this
                %
                options.endogenousConcepts (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) {mustBeNonempty}
                options.units (1, :) string {mustBeNonempty}
                %
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockConcepts (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            %
            this.EndogenousConcepts = options.endogenousConcepts;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            this.Units = options.units;
            %
            this.ExogenousNames = options.exogenousNames;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
            %
            this.populateShockConcepts(options.shockConcepts);
            this.IdentificationHorizon = options.identificationHorizon;
            %
            this.catchDuplicateNames();
        end%


        % function populateShockConcepts(this, shockConcepts)
        %     if ~isempty(shockConcepts)
        %         this.ShockConcepts = shockConcepts;
        %     else
        %         this.ShockConcepts = meta.autogenerateShockConcepts(this.NumEndogenousConcepts);
        %     end
        %     if this.NumShockNames ~= this.NumEndogenousNames
        %         error("Number of shock names must match number of endogenous variables");
        %     end
        % end%


        % function emptyYLX = createEmptyYLX(this)
        %     numY = this.NumEndogenousNames;
        %     numL = this.NumEndogenousNames * this.Order;
        %     numX = double(this.HasIntercept) + this.NumExogenousNames;
        %     emptyYLX = { ...
        %         zeros(0, numY), ...
        %         zeros(0, numL + numX), ...
        %     };
        % end%


        % function residualNames = getResidualNames(this)
        %     residualNames = meta.concatenate(this.ResidualPrefix, [this.EndogenousNames]);
        % end%

    end


    % methods (Access=protected)
    %     function catchDuplicateNames(this)
    %         allNames = [ ...
    %             this.EndogenousNames, ...
    %             this.ExogenousNames, ...
    %             this.ShockNames ...
    %         ];
    %         if numel(allNames) ~= numel(unique(allNames))
    %             nonuniques = textual.nonunique(allNames);
    %             error("Duplicate model name(s): " + join(nonuniques, ", "));
    %         end
    %     end%
    % end


    % Reduced-form dependent properties
    methods
        function out = getMeta(this)
            out = this;
        end%

        function out = get.EndogenousNames(this)
            out = string.empty(1, 0);
            for unit = this.Units
                out = [out, meta.concatenate(unit, this.EndogenousConcepts)];
            end
        end%

        function num = get.NumEndogenousNames(this)
            num = this.NumEndogenousConcepts * this.getNumUnits();
        end%

        function num = get.NumExogenousNames(this)
            num = numel(this.ExogenousNames);
        end%

        function num = get.NumEndogenousConcepts(this)
            num = numel(this.EndogenousConcepts);
        end%

        function num = get.NumResiduals(this)
            num = this.NumEndogenousNames;
        end%

        function start = get.ShortStart(this)
            start = this.ShortSpan(1);
        end%

        function out = get.ShortEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.EstimationSpan(this)
            out = this.ShortSpan;
        end%

        function out = get.EstimationStart(this)
            out = this.ShortSpan(1);
        end%

        function out = get.EstimationEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.InitSpan(this)
            out = datex.span(this.InitStart, this.InitEnd);
        end%

        function out = get.InitStart(this)
            out = datex.shift(this.ShortSpan(1), -this.Order);
        end%

        function out = get.InitEnd(this)
            out = datex.shift(this.ShortSpan(1), -1);
        end%

        function out = get.LongStart(this)
            out = datex.shift(this.ShortStart, -this.Order);
        end%

        function out = get.LongEnd(this)
            out = this.ShortEnd;
        end%

        function out = get.LongSpan(this)
            out = datex.span(this.LongStart, this.LongEnd);
        end%

        function out = get.NumShortSpan(this)
            out = numel(this.ShortSpan);
        end%

        function out = get.HasExogenous(this)
            out = ~isempty(this.ExogenousNames);
        end%
    end


    % Structural dependent properties
    methods
        function out = get.NumShockConcepts(this)
            out = numel(this.ShockConcepts);
        end%

        function out = get.NumShocks(this)
            out = this.getNumUnits() * this.NumShockConcepts;
        end%

        function out = get.NumShockNames(this)
            out = this.NumShocks;
        end%

        function out = get.ShockNames(this)
            out = this.ShockConcepts;
        end%
    end


    methods % Panel
        function out = getNumSeparableUnits(this)
            if this.HasSeparableUnits
                out = this.getNumUnits();
            else
                out = 1;
            end
        end%

        function out = getNumUnits(this)
            num = numel(this.Units);
        end%

        function out = getSeparableEndogenousNames(this)
            if this.HasSeparableUnits
                out = this.EndogenousConcepts;
            else
                out = this.EndogenousNames;
            end
        end%

        function out = getSeparableShockNames(this)
            if this.HasSeparableUnits
                out = this.ShockConcepts;
            else
                out = this.ShockNames;
            end
        end%
    end

end

