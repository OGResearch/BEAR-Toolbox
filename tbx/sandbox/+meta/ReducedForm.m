
% meta.ReducedForm  Meta class for reduced-form VAR models

classdef ReducedForm < handle

    properties (SetAccess=protected)
        % EndogenousConcepts  Names of endogenous concepts
        EndogenousConcepts (1, :) string

        % Units  Names of units in panel models
        Units (1, :) string = ""

        % ExogenousNames  Names of exogenous variables
        ExogenousNames (1, :) string

        % ReducibleNames  Names of reducible variables
        ReducibleNames (1, :) string = string.empty(1, 0)

        % ResidualPrefix  Prefix prepended to the names of residuals
        ResidualPrefix (1, 1) string = "resid"

        % Order  Order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1

        % HasIntercept  Presence of an intercept (constant) in the model
        HasIntercept (1, 1) logical

        % NumFactors  Number of factors to be formed from reducibles
        NumFactors (1, 1) double {mustBeInteger, mustBePositive} = 1
    end

    properties
        % HasCrossUnits  True if the model has cross-effects between units
        HasCrossUnits (1, 1) logical = false
    end

    properties (SetAccess=protected)
        % Span of fitted data
        ShortSpan

        % Separator
        SEPARATOR = "_"
    end

    properties (Dependent)
        ShortStart
        ShortEnd
    end

    properties (Dependent)
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
        NumResiduals

        EstimationSpan
        EstimationStart
        EstimationEnd
        InitSpan
        InitStart
        InitEnd
        LongStart
        LongEnd
        LongSpan
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.endogenousConcepts (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) datetime {mustBeNonempty}

                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.units (1, :) string = ""
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
            end
            %
            this.EndogenousConcepts = options.endogenousConcepts;
            this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            if isempty(this.ShortSpan)
                error("Estimation span must be non-empty");
            end
            %
            this.Units = options.units;
            this.ExogenousNames = options.exogenousNames;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
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
            if this.HasCrossUnits
                numY = this.NumEndogenousNames;
                numL = this.NumEndogenousNames * this.Order;
                numPages = 1;
            else
                numY = this.NumEndogenousConcepts;
                numL = this.NumEndogenousConcepts * this.Order;
                numPages = this.NumUnits;
            end
            numX = double(this.HasIntercept) + this.NumExogenousNames;
            emptyYLX = { ...
                zeros(0, numY, numPages), ...
                zeros(0, numL + numX, numPages), ...
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

        function dataArray = reshapeCrossUnitData(this, dataArray)
            arguments
                this
                dataArray double
            end
            if this.HasCrossUnits || this.NumUnits == 1
                return
            end
            dataArray = reshape(dataArray, size(dataArray, 1), [], this.NumUnits);
        end%
    end

    methods
        function out = get.EndogenousNames(this)
            out = string.empty(1, 0);
            for unit = this.Units
                out = [out, meta.concatenate(unit, this.EndogenousConcepts)];
            end
        end%

        function out = get.ResidualNames(this)
            out = meta.concatenate(this.ResidualPrefix, this.EndogenousNames);
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

        function num = get.NumResiduals(this)
            num = this.NumEndogenousNames;
        end%

        function start = get.ShortStart(this)
            start = this.ShortSpan(1);
        end%

        function end_ = get.ShortEnd(this)
            end_ = this.ShortSpan(end);
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

end

