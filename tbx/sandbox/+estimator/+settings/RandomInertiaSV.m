classdef (CaseInsensitiveProperties=true) RandomInertiaSV < estimator.settings.Base

    properties
        HeteroskedasticityAutoRegressionMean double = 1
        HeteroskedasticityShape double = 1e-3
        HeteroskedasticityScale double = 1e-3
        HeteroskedasticityAutoRegressionVariance double = 1e-2

    end


end

