
classdef ReducedForm < handle & model.PresampleMixin & model.TabulateMixin

    properties (Constant, Hidden)
        DEFAULT_STABILITY_THRESHOLD = Inf % 1 - 1e-10
        %
        ESTIMATOR_DISPATCHER = struct( ...
            lower("NormalWishart"), @red.NormalWishartEstimator ...
        )
    end


    properties
        Meta
        DataHolder
        Dummies (1, :) cell = cell.empty(1, 0)
        Estimator
    end


    properties
        Presampled (1, :) cell = cell.empty(1, 0)
        ExogenousMean (1, :) double
    end


    properties (Hidden)
        StabilityThreshold (1, 1) double = model.ReducedForm.DEFAULT_STABILITY_THRESHOLD
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
                options.Meta (1, 1) model.Meta
                options.DataHolder (:, :) model.DataHolder
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
            this.Meta.HasCrossUnits = this.Estimator.HasCrossUnits;
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


        function longYXZ = getLongYXZ(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longYXZ = this.getSomeYXZ(longSpan);
        end%


        function shortYXZ = getShortYXZ(this)
            shortYXZ = this.getSomeYXZ(this.Meta.ShortSpan);
        end%


        function initYXZ = getInitYXZ(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            initSpan = datex.initSpanFromShortSpan(shortSpan, this.Meta.Order);
            initYXZ = this.getSomeYXZ(initSpan);
        end%


        function someYXZ = getSomeYXZ(this, span)
            someYXZ = this.DataHolder.getYXZ(span=span);
            someYXZ{1} = this.Meta.reshapeCrossUnitData(someYXZ{1});
        end%


        function [longYXZ, dummiesYLX, indivDummiesYLX] = initialize(this)
            shortSpan = this.Meta.ShortSpan;
            longYXZ = this.getLongYXZ();
            this.estimateExogenousMean(longYXZ);
            [dummiesYLX, indivDummiesYLX] = this.generateDummiesYLX(longYXZ);
            this.Estimator.initialize(this.Meta, longYXZ, dummiesYLX);
        end%


        function estimateExogenousMean(this, longYXZ)
            [~, longX, ~] = longYXZ{:};
            this.ExogenousMean = mean(longX, 1, "omitNaN");
        end%


        % function ameanY = asymptoticMean(this)
        %     % TODO: Reimplement for time-varying models
        %     this.resetPresampledIndex();
        %     numPresampled = this.NumPresampled;
        %     ameanX = this.ExogenousMean;
        %     ameanY = nan(1, this.Meta.NumLhsColumns, numPresampled);
        %     for i = 1 : numPresampled
        %         redSystem = this.nextPresampledSystem();
        %         ameanY(1, :, i) = reshape(system.asymptoticMean(redSystem, ameanX), [], 1);
        %     end
        %     rows = missing;
        %     ameanY = tablex.fromNumericArray( ...
        %         ameanY, this.Meta.EndogenousNames, rows, variantDim=3 ...
        %     );
        % end%


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
            if this.StabilityThreshold < Inf
                sampler = this.decorateStability(sampler);
            end
        end%


        function out = getSystemSampler(this)
            sampler = this.getSampler();
            %
            meta = this.Meta;
            function [system, sample] = systemSampler()
                sample = sampler();
                system = meta.systemFromSample(sample);
            end%
            %
            out = @systemSampler;
        end%


        function outSampler = decorateStability(this, inSampler)
            meta = this.Meta;
            threshold = this.StabilityThreshold;
            %
            function sample = samplerWithStabilityCheck()
                while true
                    sample = inSampler();
                    A = meta.ayeFromSample(sample);
                    if system.stability(A, threshold)
                        break
                    end
                end
            end%
            %
            outSampler = @samplerWithStabilityCheck;
        end%


        function outTable = forecast(this, forecastSpan, options)
            arguments
                this
                forecastSpan (1, :) datetime
                %
                options.StochasticResiduals (1, 1) logical = true
                options.IncludeInitial (1, 1) logical = true
            end
            %
            variantDim = 3;
            meta = this.Meta;
            forecastStart = forecastSpan(1);
            forecastEnd = forecastSpan(end);
            shortForecastSpan = datex.span(forecastStart, forecastEnd);
            this.checkForecastSpan(forecastStart, forecastEnd);
            forecastStartIndex = datex.diff(forecastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortForecastSpan);
            longForecastSpan = datex.longSpanFromShortSpan(shortForecastSpan, meta.Order);
            longYXZ = this.getSomeYXZ(longForecastSpan);
            %
            % Loop over all samples
            numPresampled = this.NumPresampled;
            Y = cell(1, numPresampled);
            U = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [Y{i}, U{i}, initY{i}] = this.forecast4S( ...
                    sample, longYXZ, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end
            YU = [cat(variantDim, Y{:}), cat(variantDim, U{:})];
            outSpan = shortForecastSpan;
            %
            % Create and add initial condition if requested
            if options.IncludeInitial
                initY = cat(variantDim, initY{:});
                initU = nan(size(initY));
                YU = [[initY, initU]; YU];
                outSpan = longForecastSpan;
            end
            %
            outNames = [meta.EndogenousNames, meta.ResidualNames];
            outTable = tablex.fromNumericArray(YU, outNames, outSpan, variantDim=variantDim);
        end%


        function [y, u, initY] = forecast4S(this, sample, longYXZ, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYXZ (1, 3) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            %
            meta = this.Meta;
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            numP = meta.NumSeparableUnits;
            y = cell(1, numP);
            u = cell(1, numP);
            initY = cell(1, numP);
            for i = 1 : numP
                %
                % Extract unit-specific data
                unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i), longYXZ(2), longYXZ(3)];
                unitSigma = meta.extractUnitFromCells(draw.Sigma, i);
                unitA = meta.extractUnitFromCells(draw.A, i);
                unitC = meta.extractUnitFromCells(draw.C, i);
                %
                % Generate unit-specific residuals
                u{i} = system.generateResiduals( ...
                    unitSigma ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                %
                % Run unit-specific forecast
                [y{i}, initY{i}] = system.forecast( ...
                    unitA, unitC, unitYXZ, u{i} ...
                    , hasIntercept=options.HasIntercept ...
                    , order=options.Order ...
                );
            end
            y = cat(2, y{:});
            u = cat(2, u{:});
            initY = cat(2, initY{:});
        end%

    end


    methods
        function str = get.StabilityThresholdString(this)
            str = sprintf("%.16f", this.StabilityThreshold);
        end%

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
            if this.StabilityThreshold < Inf
                out = this.decorateStability(out);
            end
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
%{
% # calculateResiduals
%
% {==Calculate reduced-form residuals==}
%
%}
            meta = this.Meta;
            longYXZ = this.getLongYXZ();
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateResiduals4S(sample, longYXZ);
            end%
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @nan, ...
                "dimNames", {meta.ResidualNames}, ...
                options{:} ...
            );
        end%


        function [u, sample] = estimateResiduals4S(this, sample, longYXZ)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            numP = meta.NumSeparableUnits;
            u = cell(1, numP);
            for i = 1 : numP
                unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i), longYXZ(2), longYXZ(3)];
                unitA = meta.extractUnitFromCells(draw.A, i);
                unitC = meta.extractUnitFromCells(draw.C, i);
                u{i} = system.calculateResiduals( ...
                    unitA, unitC, unitYXZ ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end
            u = cat(2, u{:});
        end%


        function varargout = calculateResiduals(this, varargin)
            [varargout{1:nargout}] = this.estimateResiduals(varargin{:});
        end%


        function checkForecastSpan(this, forecastStart, forecastEnd)
            beforeStart = datex.shift(forecastStart, -1);
            if ~any(beforeStart == this.Meta.ShortSpan)
                error("Forecast start period out of range");
            end
            if ~this.Meta.HasExogenous
                return
            end
            if ~any(forecastEnd == this.DataHolder.Span)
                error("Forecast end period out of range");
            end
        end%

    end

end

