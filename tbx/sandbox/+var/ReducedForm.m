
classdef ...
    (CaseInsensitiveProperties=true) ...
    ReducedForm

    properties (Constant, Hidden)
        ESTIMATOR_DISPATCHER = struct( ...
            lower("NormalWishart"), @var.NormalWishartEstimator ...
        )
    end

    properties
        Meta
        Estimator
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

        function varargout = sample(this)
            [varargout{1:nargout}] = this.Estimator.Sampler();
        end%

        function system = sampleSystem(this, varargin)
            theta = this.Estimator.Sampler();
            meta = this.Meta;
            A = reshape(theta(meta.IndexA), meta.SizeA);
            C = reshape(theta(meta.IndexC), meta.SizeC);
            Sigma = reshape(theta(meta.IndexSigma), meta.SizeSigma);
            system = {A, C, Sigma};
        end%

        function varargout = presample(this, varargin)
            [varargout{1:nargout}] = this.Estimator.presample(varargin{:});
        end%

        function varargout = nextPresampled(this, varargin)
            theta = this.Estimator.nextPresampled(varargin{:});
        end%

        function varargout = resetPresampledCounter(this, varargin)
            [varargout{1:nargout}] = this.Estimator.resetPresampledCounter(varargin{:});
        end%

        function outTable = forecast(this, inTable, span, options)
            arguments
                this
                inTable timetable
                span (1, :) datetime
                options.Variant (1, 1) double = 1
            end

            span = datex.span(span(1), span(end));
            YX = this.Meta.getData( ...
                inTable, periods ...
                , removeMissing=false ...
                , variant=options.Variant ...
            );
            Y = this.simulate(YX);
        end%

        function Y = simulate(this, YX)
            arguments
                this
                inYX (2, 1) cell
            end
            system = this.sampleSystem();
            [A, C, Sigma] = system{:};
            [Y, X] = YX{:};
            numPeriods = size(Y, 1);
            numY = size(Y, 2);
            x = 
            for t = 1 : numPeriods
                Y(t, :) = C*X(t, :);
                if t < numPeriods
                    X(t+1, 1:numY) = Y(t, :);
                end
            end
        end%

        function display(this)
            disp(" ")
            disp("ReducedForm VAR")
            disp(" ")
            display(this.Meta)
            display(this.Estimator)
        end%

        function disp(this)
            this.display();
        end%

    end

end

