
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

        function varargout = presample(this, varargin)
            [varargout{1:nargout}] = this.Estimator.presample(varargin{:});
        end%

        function varargout = nextPresampled(this, varargin)
            [varargout{1:nargout}] = this.Estimator.nextPresampled(varargin{:});
        end%

        function varargout = resetPresampled(this, varargin)
            [varargout{1:nargout}] = this.Estimator.resetPresampled(varargin{:});
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

