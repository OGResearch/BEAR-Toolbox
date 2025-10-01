
classdef (CaseInsensitiveProperties=true) DynamicCrossPanel ...
    < panel.estimator.Settings

    properties
        % IG shape on residual variance
        % alpha0
        Alpha0 (1, 1) double = 1000

        % IG scale on residual variance
        % delta0
        Delta0 (1, 1) double = 1

        % IG shape on factor variance
        % a0
        A0 (1, 1) double = 1000

        % IG scale on factor variance
        % b0
        B0 (1, 1) double = 1

        % AR coefficient on factors
        % rho
        Rho (1, 1) double = 0.75

        % Variance of Metropolis draw
        % psi
        Psi (1, 1) double = 0.1

        % AR coefficient on residual variance
        % gamma
        Gamma (1, 1) double = 0.85
    end

end

