
classdef ReducedForm < handle

    properties (Constant, Hidden)

        DEFAULT_STABILITY_THRESHOLD = 1 - 1e-10

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
        PresampledIndex (1, 1) double = 0
        ExogenousMean (1, :) double
    end

    properties (Hidden)
        StabilityThreshold (1, 1) double = model.ReducedForm.DEFAULT_STABILITY_THRESHOLD
    end

    properties (Hidden, SetAccess = protected)
        LongYXZ (1, 3) cell
    end

    properties (Dependent)
        StabilityThresholdString (1, 1) string
        NumPresampled (1, 1) double
        HasDummies (1, 1) logical
        NumDummies (1, 1) double
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.Meta (1, 1) meta.ReducedForm
                options.Data (1, 1) data.DataHolder
                options.Estimator (1, 1) estimator.Base
                options.Dummies (1, :) cell = cell.empty(1, 0)
                options.StabilityThreshold (1, 1) double = NaN
            end
            this.Meta = options.Meta;
            this.DataHolder = options.Data;
            this.Dummies = options.Dummies;
            this.Estimator = options.Estimator;
            if ~isnan(options.StabilityThreshold)
                this.StabilityThreshold = options.StabilityThreshold;
            end
            this.Estimator.checkMetaConsistency(this.Meta);
        end%

        function YLX = getDataYLX(this, varargin)
            YLX = this.Meta.getDataYLX(varargin{:});
        end%

        function [longYXZ, dummiesYLX, indivDummiesYLX] = initialize(this)
            shortSpan = this.Meta.ShortSpan;
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longYXZ = this.DataHolder.getYXZ(longSpan);
            this.estimateExogenousMean(longYXZ);
            initYXZ = this.Meta.initYXZFromLongYXZ(longYXZ);
            [dummiesYLX, indivDummiesYLX] = this.generateDummiesYLX(initYXZ);
            this.Estimator.initialize(this.Meta, longYXZ, dummiesYLX);
            this.LongYXZ = longYXZ;
        end%

        function estimateExogenousMean(this, longYXZ)
            [~, longX, ~] = longYXZ{:};
            this.ExogenousMean = mean(longX, 1, "omitNaN");
        end%

        function ameanY = asymptoticMean(this)
            % TODO: Reimplement for time-varying models
            this.resetPresampledIndex();
            numPresampled = this.NumPresampled;
            ameanX = this.ExogenousMean;
            ameanY = nan(1, this.Meta.NumLhsColumns, numPresampled);
            for i = 1 : numPresampled
                redSystem = this.nextPresampledSystem();
                ameanY(1, :, i) = reshape(system.asymptoticMean(redSystem, ameanX), [], 1);
            end
            variantDim = 3;
            rows = missing;
            ameanY = tablex.fromNumericArray( ...
                ameanY, this.Meta.EndogenousNames, rows, variantDim ...
            );
        end%

        function [allDummiesYLX, indivDummiesYLX] = generateDummiesYLX(this, initYLX)
            indivDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                indivDummiesYLX{i} = this.Dummies{i}.generate(this.Meta, initYLX);
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
            meta = this.Meta;
            forecastStart = forecastSpan(1);
            forecastEnd = forecastSpan(end);
            shortForecastSpan = datex.span(forecastStart, forecastEnd);
            this.checkForecastSpan(forecastStart, forecastEnd);
            forecastStartIndex = datex.diff(forecastStart, meta.ShortStart) + 1;
            %
            forecastHorizon = numel(shortForecastSpan);
            longForecastSpan = datex.longSpanFromShortSpan(shortForecastSpan, meta.Order);
            %
            longYXZ = this.DataHolder.getYXZ(longForecastSpan);
            %
            numPresampled = this.NumPresampled;
            this.resetPresampledIndex();
            %
            Y0 = nan(meta.Order, meta.NumEndogenousNames, numPresampled);
            Y = nan(forecastHorizon, meta.NumEndogenousNames, numPresampled);
            U = nan(forecastHorizon, meta.NumEndogenousNames, numPresampled);
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
                %
                u = system.sampleResiduals( ...
                    draw.Sigma ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                [y, init] = system.forecast(draw.A, draw.C, longYXZ, u, meta.HasIntercept, meta.Order);
                U(:, :, i) = u;
                Y(:, :, i) = y;
                Y0(:, :, i) = init;
            end
            %
            outSpan = shortForecastSpan;
            if options.IncludeInitial
                Y = [Y0; Y];
                U = [nan(meta.Order, size(U, 2), numPresampled); U];
                outSpan = longForecastSpan;
            end
            %
            outNames = [meta.EndogenousNames, meta.ResidualNames];
            variantDim = 3;
            outTable = tablex.fromNumericArray([Y, U], outNames, outSpan, variantDim);
        end%

    end


    methods
        function str = get.StabilityThresholdString(this)
            str = sprintf("%.16f", this.StabilityThreshold);
        end%

        function num = get.NumPresampled(this)
            num = numel(this.Presampled);
        end%

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
        end%

        function resetPresampledIndex(this)
            this.PresampledIndex = 0;
        end%

        function preallocatePresampled(this, numPresampled)
            this.Presampled = cell(1, numPresampled);
            this.resetPresampledIndex();
        end%

        function presample(this, numPresampled)
            this.preallocatePresampled(numPresampled);
            sampler = this.getSampler();
            for i = 1 : numPresampled
                this.Presampled{1, i} = sampler();
            end
            this.resetPresampledIndex();
        end%

        function residTable = residuals(this)
            % periods = this.EstimationSpan;
            % numPeriods = numel(periods);
            % dataYLX = this.getDataYLX(dataTable, periods, removeMissing=false);
            % numResiduals = this.Meta.NumResidualNames;
            % %
            % this.resetPresampledIndex();
            % numPresampled = this.NumPresampled;
            % residualData = nan(numPeriods, numResiduals, numPresampled);
            % residData = repmat({nan(numPeriods, numPresampled)}, 1, numResiduals);
            % for i = 1 : numPresampled
            %     redSystem = this.nextPresampledSystem();
            %     [A, C, Sigma] = redSystem{:};
            %     U = system.residuals(A, C, dataYLX);
            %     for j = 1 : numResiduals
            %         residData{j}(:, i) = U(:, j);
            %     end
            % end
            % residTable = tablex.fromCellArray(residData, this.Meta.ResidualNames, periods);
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

