
% meta.ReducedForm  Meta class for reduced-form VAR models

classdef ReducedForm < handle

    properties (SetAccess=protected)
        % Endogenous concepts
        EndogenousConcepts (1, :) string

        % Units in panel models
        Units (1, :) string = ""

        % Names of exogenous variables
        ExogenousNames (1, :) string

        % Names of reducible variables
        ReducibleNames (1, :) string = string.empty(1, 0)

        % Residual prefix
        ResidualPrefix (1, 1) string = "resid"

        % Order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1

        % Presence of an intercept (constant) in the model
        HasIntercept (1, 1) logical

        % Number of factors to be formed from reducibles
        NumFactors (1, 1) double {mustBeInteger, mustBePositive} = 1
    end

    properties (Hidden, SetAccess=protected)
        % Span of fitted data
        ShortSpan

        % Separator
        SEPARATOR = "_"
    end

    properties (Dependent)
        ShortStart
        ShortEnd
    end

    properties (Dependent, Hidden)
        EndogenousNames
        ResidualNames
        HasExogenous
        HasReducibles
        HasUnits

        NumEndogenousNames
        NumExogenousNames
        NumReducibleNames
        NumUnits
        NumEndogenousConcepts

        EstimationStart
        EstimationEnd
        LongStart
        LongEnd
        LongSpan
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.EndogenousConcepts (1, :) string {mustBeNonempty}
                options.EstimationSpan (1, :) datetime {mustBeNonempty}

                options.ExogenousNames (1, :) string = string.empty(1, 0)
                options.Units (1, :) string = ""
                options.Order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.Intercept (1, 1) logical = true
            end
            %
            this.EndogenousConcepts = options.EndogenousConcepts;
            this.ShortSpan = datex.span(options.EstimationSpan(1), options.EstimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            %
            this.Units = options.Units;
            this.ExogenousNames = options.ExogenousNames;
            this.HasIntercept = options.Intercept;
            this.Order = options.Order;
        end%

        function longYXZ = getLongYXZ(this, varargin)
            longYXZ = this.getSomeYXZ(@datex.longSpanFromShortSpan, varargin{:});
        end%

        function initYXZ = getInitYXZ(this, varargin)
            initYXZ = this.getSomeYXZ(@datex.initSpanFromShortSpan, varargin{:});
        end%

        function someYXZ = getSomeYXZ(this, someSpanFromShortSpan, dataTable, shortSpan, varargin)
            arguments
                this
                someSpanFromShortSpan (1, 1) function_handle
                dataTable timetable
                shortSpan (1, :) datetime
            end
            arguments (Repeating)
                varargin
            end
            someSpan = someSpanFromShortSpan(shortSpan, this.Order);
            someY = tablex.retrieveData(dataTable, this.EndogenousNames, someSpan, varargin{:});
            someX = tablex.retrieveData(dataTable, this.ExogenousNames, someSpan, varargin{:});
            someZ = tablex.retrieveData(dataTable, this.ReducibleNames, someSpan, varargin{:});
            someYXZ = {someY, someX, someZ};
        end%

        function initYXZ = initYXZFromLongYXZ(this, longXYZ)
            arguments
                this
                longXYZ (1, 3) cell
            end
            initYXZ = {
                this.initDataFromLongData(longXYZ{1}) ...
                , this.initDataFromLongData(longXYZ{2}) ...
                , this.initDataFromLongData(longXYZ{3}) ...
            };
        end%

        function initData = initDataFromLongData(this, longData)
            arguments
                this
                longData (:, :) double
            end
            initData = longData(1:this.Order, :);
        end%

        function initYLX = getInitYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.Variant (1, :) double = 1
            end
            %
            % Create initial condition span
            order = this.Order;
            startPeriod = periods(1);
            initSpan = datex.span( ...
                datex.shift(startPeriod, -order) ...
                ,  datex.shift(startPeriod, -1) ...
            );
            %
            % Call getDataYLX to get initial condition data
            initYLX = this.getDataYLX( ...
                dataTable, initSpan ...
                , variant=options.Variant ...
                , removeMissing=false ...
            );
        end%

        function [YLX, periods] = getDataYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.RemoveMissing (1, 1) logical = true
                options.Variant (1, :) double = 1
            end
            %
            numPeriods = numel(periods);
            Y = nan(numPeriods, 0);
            L = nan(numPeriods, 0);
            X = nan(numPeriods, 0);
            %
            % LHS array - current endogenous items
            for i = 1:numel(this.EndogenousItems)
                item = this.EndogenousItems{i};
                Y = [Y, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % RHS array - lags of endogenous items
            for lag = 1:this.Order
                for i = 1:numel(this.EndogenousItems)
                    item = this.EndogenousItems{i};
                    L = [L, item.getData(dataTable, periods, variant=options.Variant, shift=-lag)];
                end
            end
            %
            % RHS array - exogenous items
            for i = 1:numel(this.ExogenousItems)
                item = this.ExogenousItems{i};
                X = [X, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % Remove rows with missing observations to prepare the data for
            % estimation
            if options.RemoveMissing
                inxMissing = any(isnan(Y), 2) | any(isnan(L), 2) | any(isnan(X), 2);
                Y(inxMissing, :) = [];
                L(inxMissing, :) = [];
                X(inxMissing, :) = [];
                periods(inxMissing) = [];
            end
            %
            YLX = {Y, L, X};
        end%

        function emptyYLX = createEmptyYLX(this)
            numY = this.NumEndogenousNames;
            numL = this.NumEndogenousNames * this.Order;
            numX = this.NumExogenousNames;
            emptyYLX = { ...
                zeros(0, numY), ...
                zeros(0, numL), ...
                zeros(0, numX), ...
            };
        end%

        function emptyYXZ = createEmptyYXZ(this)
            numY = this.NumEndogenousNames;
            numX = this.NumExogenousNames;
            numZ = this.NumReducibleNames;
            emptyYXZ = { ...
                zeros(0, numY), ...
                zeros(0, numX), ...
                zeros(0, numZ), ...
            };
        end%

        function A = ayeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
        end%

        function [A, C] = ayeCeeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
            C = B(this.SizeA(1)+1:end, :);
        end%

        function Sigma = sigmaFromSample(this, sample)
            Sigma = reshape(sample{2}, this.SizeSigma);
        end%

        function system = systemFromSample(this, sample)
            [A, C] = this.ayeCeeFromSample(sample);
            Sigma = reshape(sample{2}, this.SizeSigma);
            system = {A, C, Sigma};
        end%

        function sample = preallocateRedSample(this, numSamples)
            sample = {nan(this.NumelB, numSamples), nan(this.NumelSigma, numSamples)};
        end%
    end

    methods
        function names = get.EndogenousNames(this)
            names = string.empty(1, 0);
            for unit = this.Units
                names = [names, this.concatenate(unit, this.EndogenousConcepts)];
            end
        end%

        function names = get.ResidualNames(this)
            names = this.concatenate(this.ResidualPrefix, this.EndogenousNames);
        end%

        function num = get.NumEndogenousNames(this)
            num = this.NumEndogenousConcepts * this.NumUnits;
        end%

        function num = get.NumExogenousNames(this)
            num = numel(this.ExogenousNames);
        end%

        function num = get.NumReducibleNames(this)
            num = numel(this.ReducibleNames);
        end%

        function num = get.NumUnits(this)
            num = numel(this.Units);
        end%

        function num = get.NumEndogenousConcepts(this)
            num = numel(this.EndogenousConcepts);
        end%

        function start = get.ShortStart(this)
            start = this.ShortSpan(1);
        end%

        function end_ = get.ShortEnd(this)
            end_ = this.ShortSpan(end);
        end%

        function start = get.EstimationStart(this)
            start = this.ShortSpan(1);
        end%

        function end_ = get.EstimationEnd(this)
            end_ = this.ShortSpan(end);
        end%

        function start = get.LongStart(this)
            start = datex.shift(this.ShortStart, -this.Order);
        end%

        function end_ = get.LongEnd(this)
            end_ = this.ShortEnd;
        end%

        function span = get.LongSpan(this)
            span = datex.span(this.LongStart, this.LongEnd);
        end%

        function out = get.HasExogenous(this)
            out = ~isempty(this.ExogenousNames);
        end%

        function out = get.HasReducibles(this)
            out = ~isempty(this.ReducibleNames);
        end%

        function out = get.HasUnits(this)
            out = ~isequal(this.Units, "");
        end%
    end

    methods (Access=protected)
        function fullNames = concatenate(this, prefix, names)
            arguments
                this
                prefix (1, 1) string
                names (1, :) string
            end
            if prefix == ""
                fullNames = names;
                return
            end
            fullNames = prefix + this.SEPARATOR + names;
        end%
    end

end

