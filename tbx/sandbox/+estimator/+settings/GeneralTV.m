classdef (CaseInsensitiveProperties=true) GeneralTV < estimator.settings.Base

    properties
        HeteroskedasticityAutoRegression double = 1
        HeteroskedasticityShape double = 1e-3
        HeteroskedasticityScale double = 1e-3

    end


end

