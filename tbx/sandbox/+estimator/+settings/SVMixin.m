classdef (CaseInsensitiveProperties=true) SVMixin < handle

    properties
        HeteroskedasticityAutoRegression double = 1 %gamma
        HeteroskedasticityShape double = 1e-3 %alpha
        HeteroskedasticityScale double = 1e-3 %delta
    end

end