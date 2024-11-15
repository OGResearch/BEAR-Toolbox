classdef (CaseInsensitiveProperties=true) DynamicCrossPanel < estimator.settings.Base

    properties

        % Alpha0  IG shape on residual variance
        Alpha0 (1, 1) double = 1000

        % Delta0  IG scale on residual variance
        Delta0 (1, 1) double = 1

        % A0  Hyperparameter: a0
        A0 (1, 1) double = 1000

        % B0  Hyperparameter: b0
        B0 (1, 1) double = 1

        % Rho  Hyperparameter: rho
        Rho (1, 1) double = 0.75

        % Psi  Hyperparameter: psi
        Psi (1, 1) double = 0.1

        % Gamma  AR coefficient on residual variance
        Gamma (1, 1) double = 0.85

    end
end

