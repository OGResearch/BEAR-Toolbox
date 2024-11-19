classdef (CaseInsensitiveProperties=true) HierarchicalPanel < estimator.settings.Base

    properties

        % S0: hyperparameter: s0
        S0 (1, 1) double = 0.001

        % V0: hyperparameter: v0
        V0 (1, 1) double = 0.001   

    end

end

