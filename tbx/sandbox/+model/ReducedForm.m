
classdef ReducedForm < handle & model.PresampleMixin

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
        ExogenousMean (1, :) double
    end


    properties (Hidden)
        StabilityThreshold (1, 1) double = model.ReducedForm.DEFAULT_STABILITY_THRESHOLD
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
                options.DataHolder (:, :) data.DataHolder
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

        function longYXZ = getLongYXZ(this)
            longYXZ = this.getSomeYXZ(this.Meta.LongSpan);
        end%

        function shortYXZ = getShortYXZ(this)
            shortYXZ = this.getSomeYXZ(this.Meta.ShortSpan);
        end%

        function initYXZ = getInitYXZ(this)
            initYXZ = this.getSomeYXZ(this.Meta.InitSpan);
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
            longYXZ = this.getSomeYXZ(longForecastSpan);
            %
            numPresampled = this.NumPresampled;
            %
            % Multiple-unit output data will be always captured as flat
            Y0 = nan(meta.Order, meta.NumEndogenousNames, numPresampled);
            Y = nan(forecastHorizon, meta.NumEndogenousNames, numPresampled);
            U = nan(forecastHorizon, meta.NumEndogenousNames, numPresampled);
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
                %
                % Multiple-unit data are 3D
                u = system.sampleResiduals( ...
                    draw.Sigma ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                %
                % Multiple-unit data are 3D
                [y, init] = system.forecast( ...
                    draw.A, draw.C, longYXZ, u ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
                %
                % Flatten multiple-unit data back
                U(:, :, i) = u(:, :);
                Y(:, :, i) = y(:, :);
                Y0(:, :, i) = init(:, :);
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
            outTable = tablex.fromNumericArray([Y, U], outNames, outSpan, variantDim=3);
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

        function clearPresampled(this)
            this.Presampled = cell.empty(1, 0);
        end%

        function outTable = calculateResiduals(this)
%{
% # calculateResiduals
%
% {==Calculate reduced-form residuals==}
%
%}
            meta = this.Meta;
            longSpan = meta.LongSpan;
            shortSpan = meta.ShortSpan;
            numShortPeriods = numel(shortSpan);
            numPresampled = this.NumPresampled;
            numResiduals = meta.NumResiduals;
            U = nan(numShortPeriods, numResiduals, numPresampled);
            residualTableData = repmat({nan(numShortPeriods, numPresampled)}, 1, numResiduals);
            longYXZ = this.DataHolder.getYXZ(span=meta.LongSpan);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                u = this.calculateSampleResiduals(sample, longYXZ);
                for j = 1 : numResiduals
                    residualTableData{j}(:, i) = u(:, j);
                end
            end
            outTable = tablex.fromCellArray(residualTableData, meta.ResidualNames, shortSpan);
        end%

        function u = calculateSampleResiduals(this, sample, longYXZ)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            u = system.residuals( ...
                draw.A, draw.C, longYXZ ...
                , hasIntercept=meta.HasIntercept ...
                , order=meta.Order ...
            );
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

