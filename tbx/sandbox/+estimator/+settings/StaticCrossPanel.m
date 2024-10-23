classdef (CaseInsensitiveProperties=true) StaticCrossPanel < estimator.settings.Base

    properties

        % IG shape on residual variance
        Alpha0 (1, 1) double = 1000

        % IG scale on residual variance
        Delta0 (1, 1) double = 1

    end

end

