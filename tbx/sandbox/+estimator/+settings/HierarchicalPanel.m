classdef (CaseInsensitiveProperties=true) HierarchicalPanel < estimator.settings.Base

    properties

        % hyperparameter: s0
        S0 (1, 1) double = 0.001

        % hyperparameter: v0
        V0 (1, 1) double = 0.001   

    end

end

