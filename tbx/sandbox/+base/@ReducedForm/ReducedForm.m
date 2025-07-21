
classdef ReducedForm < handle & base.PresampleMixin & base.TabulateMixin

    properties (Constant, Hidden)
        DEFAULT_STABILITY_THRESHOLD = Inf % 1 - 1e-10
        %
    end


    properties
        Meta
        DataHolder
        Dummies (1, :) cell = cell.empty(1, 0)
        Estimator
    end


    properties
        Presampled (1, :) cell = cell.empty(1, 0)
    end


    properties (Hidden)
        StabilityThreshold (1, 1) double = base.ReducedForm.DEFAULT_STABILITY_THRESHOLD
    end


    properties (Dependent)
        StabilityThresholdString (1, 1) string
        HasDummies (1, 1) logical
        NumDummies (1, 1) double

        Sampler
        IdentificationDrawer
        HistoryDrawer
        ConditionalDrawer
        UnconditionalDrawer

        SampleCounter
        CandidateCounter
    end


    methods

        function this = ReducedForm(options)
            arguments
                options.Meta (1, 1) base.Meta
                options.DataHolder (:, :) base.DataHolder
                options.Estimator (1, 1) estimator.Base
                options.Dummies (1, :) cell = cell.empty(1, 0)
                options.StabilityThreshold (1, 1) double = NaN
            end
            %
            this.Meta = options.Meta;
            this.DataHolder = options.DataHolder;
            this.Dummies = options.Dummies;
            this.Estimator = options.Estimator;
            if ~isnan(options.StabilityThreshold)
                this.StabilityThreshold = options.StabilityThreshold;
            end
            this.Estimator.checkConsistency(this.Meta, this.Dummies);
        end%


        function resetPresampled(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
            end
            this.Presampled = cell(1, numToPresample);
        end%


        function storePresampled(this, index, sample)
            this.Presampled{index} = sample;
        end%


        function longYX = getLongYX(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longYX = this.getSomeYX(longSpan);
        end%


        function shortYX = getShortYX(this)
            shortYX = this.getSomeYX(this.Meta.ShortSpan);
        end%


        function initYX = getInitYX(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            initSpan = datex.initSpanFromShortSpan(shortSpan, this.Meta.Order);
            initYX = this.getSomeYX(initSpan);
        end%


        function someYX = getSomeYX(this, span)
            someYX = this.DataHolder.getYX(span=span);
        end%


        function [longYX, dummiesYLX, indivDummiesYLX] = initialize(this)
            longYX = this.getLongYX();
            [dummiesYLX, indivDummiesYLX] = this.generateDummiesYLX(longYX);
            this.Estimator.initialize(this.Meta, longYX, dummiesYLX);
        end%


        function [allDummiesYLX, indivDummiesYLX] = generateDummiesYLX(this, longYLX)
            indivDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                indivDummiesYLX{i} = this.Dummies{i}.generate(this.Meta, longYLX);
            end
            allDummiesYLX = this.Meta.createEmptyYLX();
            allDummiesYLX = system.mergeDataCells(allDummiesYLX, indivDummiesYLX{:});
        end%


        function sampler = getSampler(this)
            sampler = this.Estimator.Sampler;
            % if this.StabilityThreshold < Inf
            %     sampler = this.decorateStability(sampler);
            % end
        end%


        function [forecaster, tabulator] = prepareForecaster(this, shortFcastSpan, options)

            arguments
                this
                shortFcastSpan (1, :) datetime
                options.StochasticResiduals
                options.IncludeInitial
            end

            variantDim = 3;
            meta = this.Meta;
            fcastStart = shortFcastSpan(1);
            fcastEnd = shortFcastSpan(end);
            this.checkForecastSpan(fcastStart, fcastEnd);
            forecastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortFcastSpan);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            longYX = this.getSomeYX(longFcastSpan);

            outNames = this.getForecastVarNames(meta);
            order = meta.Order;
            numX = meta.NumExogenousNames;

            function [shortY, shortU, initY, shortX, draw] = forecaster__(sample)

                meta = this.Meta;
                [shortY, shortU, initY, shortX, draw] = this.forecast4S( ...
                    sample, longYX, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=order ...
                );

            end%

            function outTable = tabulator__(shortY, shortU, initY, shortX)
                numPresampled = numel(shortY);
                shortY = cat(variantDim, shortY{:});
                shortU = cat(variantDim, shortU{:});
                shortX = cat(variantDim, shortX{:});

                if options.IncludeInitial
                    outSpan = longFcastSpan;
                    initY = cat(variantDim, initY{:});
                    initU = nan(size(initY));
                    initX = nan([order, numX, numPresampled]);
                    outData = this.assembleOutData(initY, initU, initX, shortY, shortU, shortX);
                else
                    outSpan = shortFcastSpan;
                    outData = this.assembleOutData([], [], [], shortY, shortU, shortX);
                end

                outTable = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=variantDim);
            end%

            forecaster = @forecaster__;
            tabulator = @tabulator__;
        end%


        function varargout = forecast(this, fcastSpan, options)

            arguments
                this
                fcastSpan (1, :) datetime
                options.StochasticResiduals (1, 1) logical = false
                options.IncludeInitial (1, 1) logical = false
            end

            fcastSpan = datex.ensureSpan(fcastSpan);

            [forecaster, tabulator] = this.prepareForecaster( ...
                fcastSpan, ...
                stochasticResiduals=options.StochasticResiduals, ...
                includeInitial=options.IncludeInitial ...
            );

            numPresampled = this.NumPresampled;
            shortY = cell(1, numPresampled);
            shortU = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            shortX = cell(1, numPresampled);

            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [shortY{i}, shortU{i}, initY{i}, shortX{i}] = forecaster(sample);
            end

            [varargout{1:nargout}] = tabulator(shortY, shortU, initY, shortX);

        end


        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longYX, forecastStartIndex, forecastHorizon, options)

            arguments
                this
                sample
                longYX (1, 2) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                %
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end

            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            shortU = system.generateResiduals( ...
                draw.Sigma ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            order = options.Order;

            % Run forecast
            [longY, longX] = longYX{:};
            initY = this.getInitY(longY, order, sample, forecastStartIndex);
            shortX = longX(order+1:end, :);

            shortY = system.forecastBase( ...
                draw.A, draw.C, initY, shortX, shortU ...
                , hasIntercept=options.HasIntercept ...
            );

        end%


    end

    methods (Access = protected)

        function initY = getInitY(this, longY, order, ~, ~)
            % Superclass uses longY and order only
            initY = longY(1:order, :);
        end

        function longY = getLongY4Resid(this, longY, ~)

        end

        function outData = assembleOutData(this, initY, initU, initX, shortY, shortU, shortX)
            if isempty(initY)
                outData = [shortY, shortU, shortX];
            else
                outData = [[initY, initU, initX]; [shortY, shortU, shortX]];
            end
        end


        function forecastVarNames = getForecastVarNames(this, meta)

                forecastVarNames = [meta.EndogenousNames meta.getResidualNames, meta.ExogenousNames];

        end


    end


    methods

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
        end%

        function out = get.IdentificationDrawer(this)
            out = this.Estimator.IdentificationDrawer;
        end%

        function out = get.Sampler(this)
            out = this.Estimator.Sampler;
        end%

        function out = get.SampleCounter(this)
            out = this.Estimator.SampleCounter;
        end%

        function out = get.CandidateCounter(this)
            out = NaN;
        end%

        function out = get.HistoryDrawer(this)
            out = this.Estimator.HistoryDrawer;
        end%

        function out = get.ConditionalDrawer(this)
            out = this.Estimator.ConditionalDrawer;
        end%

        function out = get.UnconditionalDrawer(this)
            out = this.Estimator.UnconditionalDrawer;
        end%

        function varargout = estimateResiduals(this, varargin)

            meta = this.Meta;
            longYX = this.getLongYX();
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateResiduals4S(sample, longYX);
            end%

            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @nan, ...
                "dimNames", {meta.getResidualNames()}, ...
                options{:} ...
            );
        end%


        function [u, sample] = estimateResiduals4S(this, sample, longYX)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            [longY, longX] = longYX{:};
            longY = this.getLongY4Resid(longY, sample);
            u = system.calculateResiduals( ...
                draw.A, draw.C, longY, longX ...
                , hasIntercept=meta.HasIntercept ...
                , order=meta.Order ...
                );
        end%


        function varargout = calculateResiduals(this, varargin)
            [varargout{1:nargout}] = this.estimateResiduals(varargin{:});
        end%


        function checkForecastSpan(this, fcastStart, fcastEnd)
            beforeStart = datex.shift(fcastStart, -1);
            if ~any(beforeStart == this.Meta.ShortSpan)
                error("Forecast start period out of range.");
            end
            if ~this.Meta.HasExogenous
                return
            end
            if ~any(fcastEnd == this.DataHolder.Span)
                error("Forecast end period out of range.");
            end
        end%

    end

end

