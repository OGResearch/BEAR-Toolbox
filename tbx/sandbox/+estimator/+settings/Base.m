
% estimator.common  Default values for common prior distribution settings

classdef (CaseInsensitiveProperties=true) Base < settings.Base

    properties
        % Time-variant parameter estimation
        TimeVariant (1, 1) logical = false

        % Model has a constant term
        HasConstant (1, 1) logical = true

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

end

