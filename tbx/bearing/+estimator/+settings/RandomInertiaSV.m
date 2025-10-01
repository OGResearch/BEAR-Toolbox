classdef (CaseInsensitiveProperties=true) RandomInertiaSV < estimator.settings.Base & estimator.settings.SVMixin
%randominertia model, stvol=2 in bear5
    properties
        % Prior variance of inertia
        % zeta0
        HeteroskedasticityAutoRegressionVariance double = 1e-2 %zeta0

    end


end

