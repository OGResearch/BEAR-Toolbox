classdef (CaseInsensitiveProperties=true) DynamicCrossPanel < estimator.settings.Base

    properties

        % IG shape on residual variance
        Alpha0 (1, 1) double = 1000

        % IG scale on residual variance
        Delta0 (1, 1) double = 1

        % hyperparameter: a0
        A0 (1, 1) double = 1000

        % hyperparameter: b0
        B0 (1, 1) double = 1

        % hyperparameter: rho
        Rho (1, 1) double = 0.75

        % hyperparameter: psi
        Psi (1, 1) double = 0.1

        % AR coefficient on residual variance
        Gamma (1, 1) double = 0.85

    end
end
