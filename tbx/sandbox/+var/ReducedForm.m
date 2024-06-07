
classdef ...
    (CaseInsensitiveProperties=true) ...
    ReducedForm < handle

    properties (Constant, Hidden)
        ESTIMATOR_DISPATCHER = struct( ...
            lower("NormalWishart"), @var.NormalWishartEstimator ...
        )
    end

    properties
        Meta
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
    end

    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.Meta (1, :) cell
                options.Priors (1, :) cell
            end
            this.Meta = var.Meta(options.Meta{:});
            this.Estimator = this.resolvePriorOptions(options.Priors{:});
        end%

        function estimator = resolvePriorOptions(this, distributionName, varargin)
            estimator = this.ESTIMATOR_DISPATCHER.(lower(distributionName))(varargin{:});
        end%

        function varargout = initialize(this, varargin)
            [varargout{1:nargout}] = this.Estimator.initialize(this.Meta, varargin{:});
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
                    if var.system.stability(A, threshold)
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
            end

            meta = this.Meta;
            estimator = this.Estimator;

            span = datex.span(span(1), span(end));
            numPeriods = numel(span);

            YX = meta.getDataYX( ...
                inTable, span ...
                , removeMissing=false ...
                , variant=options.Variant ...
            );

            this.resetPresampledCounter();
            numPresampled = this.NumPresampled;
            Y = nan(numPeriods, meta.NumLhsColumns, numPresampled);
            U = nan(numPeriods, meta.NumLhsColumns, numPresampled);

            for i = 1 : numPresampled
                system = this.nextPresampledSystem();
                [A, C, Sigma] = system{:};

                u = var.system.sampleResiduals( ...
                    Sigma, numPeriods ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );

                y = var.system.forecast(A, C, YX, u);

                U(:, :, i) = u;
                Y(:, :, i) = y;
            end

            outNames = [meta.EndogenousNames, meta.ResidualNames];
            outTable = tablex.fromNumericArray([Y, U], outNames, span);
        end%
    end

    methods
        function num = get.NumPresampled(this)
            num = size(this.Presampled, 2);
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

        function system = nextPresampledSystem(this)
            theta = this.nextPresampled();
            system = this.systemFromTheta(theta);
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

