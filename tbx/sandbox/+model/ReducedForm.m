
classdef ReducedForm < handle

    properties (Constant, Hidden)
        ESTIMATOR_DISPATCHER = struct( ...
            lower("NormalWishart"), @reducedForm.NormalWishartEstimator ...
        )
    end

    properties
        Meta
        Dummies (1, :) cell = cell.empty(1, 0)
        Factors
        Estimator
    end

    properties (Hidden)
        Presampled (:, :) double = []

        Threshold (1, 1) struct = struct( ...
            "stationary", 1 - 1e-10 ...
            , "unit", 1 + 1e-10 ...
        )
    end

    properties (Dependent)
        NumPresampled (1, 1) double
        HasDummies (1, 1) logical
    end

    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.Meta (1, 1) model.ReducedForm.Meta
                options.Estimator
                options.Dummies (1, :) cell = cell.empty(1, 0)
                options.Factors
            end
            this.Meta = options.Meta;
            this.Dummies = options.Dummies;
            this.Estimator = options.Estimator;
        end%

        function YLX = getDataYLX(this, dataTable, periods, varargin)
            YLX = this.Meta.getDataYLX(dataTable, periods);
        end%

        function varargout = initialize(this, dataTable, periods, varargin)
            YLX = this.Meta.getDataYLX(dataTable, periods);
            [varargout{1:nargout}] = this.Estimator.initialize(this.Meta, YLX, varargin{:});
        end%

        function sampler = getSampler(this, options)
            arguments
                this
                options.Stability (1, 1) string {mustBeMember(options.Stability, ["none", "unit", "stationary"])} = "none"
            end
            sampler = this.Estimator.Sampler;
            if options.Stability ~= "none"
                sampler = this.decorateStability(sampler, options.Stability);
            end
        end%

        function out = getSystemSampler(this, varargin)
            meta = this.Meta;
            sampler = this.getSampler(varargin{:});
            function reducedFormSystem = systemSampler()
                theta = sampler();
                [A, C, Sigma] = meta.ayeCeeSigmaFromTheta(theta);
                reducedFormSystem = {A, C, Sigma};
            end%
            out = @systemSampler;
        end%

        function reducedFormSystem = systemFromTheta(this, theta)
            [A, C, Sigma] = this.Meta.ayeCeeSigmaFromTheta(theta);
            reducedFormSystem = {A, C, Sigma};
        end%

        function out = decorateStability(this, inSampler, stability)
            meta = this.Meta;
            threshold = this.Threshold.(lower(stability));
            function theta = stableSampler()
                while true
                    theta = inSampler();
                    A = meta.ayeFromTheta(theta);
                    if system.stability(A, threshold)
                        break
                    end
                end
            end%
            out = @stableSampler;
        end%

        function outTable = forecast(this, inTable, span, options)
            arguments
                this
                inTable timetable
                span (1, :) datetime

                options.Variant (1, 1) double = 1
                options.StochasticResiduals (1, 1) logical = true
                options.IncludeInitial (1, 1) logical = true
            end

            meta = this.Meta;
            estimator = this.Estimator;

            span = datex.span(span(1), span(end));
            numPeriods = numel(span);

            YLX = meta.getDataYLX( ...
                inTable, span ...
                , removeMissing=false ...
                , variant=options.Variant ...
            );

            this.resetPresampledCounter();
            numPresampled = this.NumPresampled;

            Init = nan(meta.Order, meta.NumLhsColumns, numPresampled);
            Y = nan(numPeriods, meta.NumLhsColumns, numPresampled);
            U = nan(numPeriods, meta.NumLhsColumns, numPresampled);

            for i = 1 : numPresampled
                systemMatrices = this.nextPresampledSystem();
                [A, C, Sigma] = systemMatrices{:};

                u = system.sampleResiduals( ...
                    Sigma, numPeriods ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );

                [y, init] = system.forecast(A, C, YLX, u);

                U(:, :, i) = u;
                Y(:, :, i) = y;
                Init(:, :, i) = init;
            end

            outSpan = span;
            if options.IncludeInitial
                Y = [Init; Y];
                U = [nan(meta.Order, meta.NumLhsColumns, numPresampled); U];
                outSpan = datex.span(datex.shift(span(1), -meta.Order), span(end));
            end

            outNames = [meta.EndogenousNames, meta.ResidualNames];
            outTable = tablex.fromNumericArray([Y, U], outNames, outSpan);
        end%
    end

    methods
        function num = get.NumPresampled(this)
            num = size(this.Presampled, 2);
        end%

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function theta = nextPresampled(this, numRequested)
            arguments
                this
                numRequested (1, 1) double = 1
            end
            if this.PresampledCounter + numRequested > this.NumPresampled
                error("Presampled draws not sufficient to satisfy the request");
            end
            theta = this.Presampled(:, this.PresampledCounter+(1:numRequested));
            this.PresampledCounter = this.PresampledCounter + numRequested;
        end%

        function systemMatrices = nextPresampledSystem(this)
            theta = this.nextPresampled();
            systemMatrices = this.systemFromTheta(theta);
        end%

        function resetPresampledCounter(this)
            this.PresampledCounter = 0;
        end%

        function presampled = presample(this, numPresampled, varargin)
            sampler = this.getSampler(varargin{:});
            presampled = nan(this.Meta.NumelTheta, numPresampled);
            for i = 1 : numPresampled
                presampled(:, i) = sampler();
            end
            this.Presampled = presampled;
            this.resetPresampledCounter();
        end%
    end

end

