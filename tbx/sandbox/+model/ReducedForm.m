
classdef ReducedForm < handle

    properties (Constant, Hidden)

        DEFAULT_STABILITY_THRESHOLD = 1 - 1e-10

        ESTIMATOR_DISPATCHER = struct( ...
            lower("NormalWishart"), @red.NormalWishartEstimator ...
        )

    end

    properties
        Meta
        Dummies (1, :) cell = cell.empty(1, 0)
        Factors
        Estimator
    end

    properties
        Presampled (1, 2) cell = cell(1, 2)
        PresampledCounter (1, 1) double = 0
        ExogenousMean (1, :) double
        EstimationSpan (1, :) datetime
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
                options.Estimator
                options.Dummies (1, :) cell = cell.empty(1, 0)
                options.Factors
                options.StabilityThreshold (1, 1) double = NaN
            end
            this.Meta = options.Meta;
            this.Dummies = options.Dummies;
            this.Estimator = options.Estimator;
            this.Estimator.finalizeFromMeta(this.Meta);
            if ~isnan(options.StabilityThreshold)
                this.StabilityThreshold = options.StabilityThreshold;
            end 
        end%

        function YLX = getDataYLX(this, varargin)
            YLX = this.Meta.getDataYLX(varargin{:});
        end%

        function [YLX, initYLX, dummiesYLX] = initialize(this, dataTable, periods)
            this.EstimationSpan = periods;
            YLX = this.Meta.getDataYLX(dataTable, periods);
            initYLX = this.Meta.getInitYLX(dataTable, periods);
            this.estimateExogenousMean(YLX, initYLX);
            dummiesYLX = this.generateDummiesYLS(dataTable, periods);
            allYLX = system.mergeYLX(dummiesYLX, YLX);
            this.Estimator.initialize(allYLX);
        end%

        function estimateExogenousMean(this, YLX, initYLX)
            X = YLX{3};
            initX = initYLX{3};
            this.ExogenousMean = mean([initX; X], 1, "omitNaN");
        end%

        function ameanY = asymptoticMean(this)
            % TODO: Reimplement for time-varying models
            this.resetPresampledCounter();
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

        function [allDummiesYLX, individualDummiesYLX] = generateDummiesYLS(this, dataTable, periods)
            initYLX = this.Meta.getInitYLX(dataTable, periods);
            individualDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                individualDummiesYLX{i} = this.Dummies{i}.generate(initYLX);
            end
            allDummiesYLX = this.Meta.createEmptyYLX();
            allDummiesYLX = system.mergeYLX(allDummiesYLX, individualDummiesYLX{:});
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

        function outTable = forecast(this, inTable, span, options)
            arguments
                this
                inTable timetable
                span (1, :) datetime
                %
                options.Variant (1, 1) double = 1
                options.StochasticResiduals (1, 1) logical = true
                options.IncludeInitial (1, 1) logical = true
            end
            %
            meta = this.Meta;
            estimator = this.Estimator;
            %
            span = datex.span(span(1), span(end));
            numPeriods = numel(span);
            %
            YLX = meta.getDataYLX( ...
                inTable, span ...
                , removeMissing=false ...
                , variant=options.Variant ...
            );
            %
            this.resetPresampledCounter();
            numPresampled = this.NumPresampled;
            %
            Init = nan(meta.Order, meta.NumLhsColumns, numPresampled);
            Y = nan(numPeriods, meta.NumLhsColumns, numPresampled);
            U = nan(numPeriods, meta.NumLhsColumns, numPresampled);
            %
            for i = 1 : numPresampled
                redSystem = this.nextPresampledSystem();
                [A, C, Sigma] = redSystem{:};
                %
                u = system.sampleResiduals( ...
                    Sigma, numPeriods ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                %
                y = system.forecast(A, C, YLX, u);
                init = system.extractInitial(YLX);
                %
                U(:, :, i) = u;
                Y(:, :, i) = y;
                Init(:, :, i) = init;
            end
            %
            outSpan = span;
            if options.IncludeInitial
                Y = [Init; Y];
                U = [nan(meta.Order, meta.NumLhsColumns, numPresampled); U];
                outSpan = datex.span(datex.shift(span(1), -meta.Order), span(end));
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
            num = size(this.Presampled{1}, 2);
        end%

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
        end%

        function presampled = nextPresampled(this, numRequested)
            arguments
                this
                numRequested (1, 1) double = 1
            end
            if this.PresampledCounter + numRequested > this.NumPresampled
                error("Presampled draws not sufficient to satisfy the request");
            end
            sizePresampled = numel(this.Presampled);
            presampled = cell(1, sizePresampled);
            index = this.PresampledCounter + (1 : numRequested);
            for i = 1 : sizePresampled
                presampled{i} = this.Presampled{i}(:, index, :);
            end
            this.PresampledCounter = this.PresampledCounter + numRequested;
        end%

        function redSystem = nextPresampledSystem(this)
            sample = this.nextPresampled();
            redSystem = this.Meta.systemFromSample(sample);
        end%

        function resetPresampledCounter(this)
            this.PresampledCounter = 0;
        end%

        function preallocatePresampled(this, numPresampled)
            this.Presampled = this.Estimator.Preallocator(numPresampled);
            this.resetPresampledCounter();
        end%

        function savePresampled(this, sample, index)
            for j = 1 : numel(this.Presampled)
                this.Presampled{j}(:, index, :) = sample{j};
            end
        end%

        function presampled = presample(this, numPresampled)
            this.preallocatePresampled(numPresampled);
            sampler = this.getSampler();
            for i = 1 : numPresampled
                sample = sampler();
                this.savePresampled(sample, i);
            end
            this.resetPresampledCounter();
        end%

        function residTable = residuals(this, dataTable)
            periods = this.EstimationSpan;
            numPeriods = numel(periods);
            dataYLX = this.getDataYLX(dataTable, periods, removeMissing=false);
            numResiduals = this.Meta.NumResidualColumns;
            %
            this.resetPresampledCounter();
            numPresampled = this.NumPresampled;
            residualData = nan(numPeriods, numResiduals, numPresampled);
            residData = repmat({nan(numPeriods, numPresampled)}, 1, numResiduals);
            for i = 1 : numPresampled
                redSystem = this.nextPresampledSystem();
                [A, C, Sigma] = redSystem{:};
                U = system.residuals(A, C, dataYLX);
                for j = 1 : numResiduals
                    residData{j}(:, i) = U(:, j);
                end
            end
            residTable = tablex.fromCellArray(residData, this.Meta.ResidualNames, periods);
        end%

    end

end

