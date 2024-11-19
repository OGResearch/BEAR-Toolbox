classdef (CaseInsensitiveProperties=true) StaticCrossPanel < estimator.settings.Base

    properties

        % Alpha0: IG shape on residual variance
        Alpha0 (1, 1) double = 1000

        % Delta0: IG scale on residual variance
        Delta0 (1, 1) double = 1

    end

end

