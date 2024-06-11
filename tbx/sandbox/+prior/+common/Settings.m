
% prior.common.Settings  Default values for common prior distribution settings

classdef (CaseInsensitiveProperties=true) Settings < settings.Base

    properties
        % Number of burn-in draws
        Burnin (1, 1) double = 0

        % 
        Exogenous (1, 1) logical = false

        % Autoregression
        Autoregression (1, 1) double = 0.8

        Lambda1 double = 0.1
        Lambda2 double = 0.5
        Lambda3 double = 1
        Lambda4 double = 100
        Lambda5 double = 0.001

        % Prior type for the covariance matrix of residuals
        Sigma (1, 1) string {ismember(Sigma, ["eye", "ar", "var"])} = "eye"
    end

end

