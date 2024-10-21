
% estimator.common  Default values for common prior distribution settings

classdef (CaseInsensitiveProperties=true) Base < settings.Base

    properties
        % Time-variant parameter estimation
        TimeVariant (1, 1) logical = false

        % Model has a constant term
        HasConstant (1, 1) logical = true

        % Number of lags
        Order (1, 1) double = 1

        % Number of burn-in draws
        Burnin (1, 1) double = 0

        % 
        Exogenous (:, :) logical = false

        % 
        BlockExogenous (:, :) logical = false


        % Autoregression
        Autoregression (:, 1) double = 0.8

        Lambda1 double = 0.1
        Lambda2 double = 0.5
        Lambda3 double = 1
        Lambda4 (:, :) double = 100
        Lambda5 double = 0.001

    end

    methods
        function this = Base(meta, varargin)
            this = this@settings.Base(varargin{:});
            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            numXI = numX + double(meta.HasIntercept);
            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numXI);
            end
            if isscalar(this.Lambda4)
                this.Lambda4 = repmat(this.Lambda4, numY, numXI);
            end
            if isscalar(this.Autoregression)
                this.Autoregression = repmat(this.Autoregression, numY, 1);
            end
        end%
    end

end

