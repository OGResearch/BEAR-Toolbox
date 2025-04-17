classdef (CaseInsensitiveProperties=true) CCMMSV < estimator.settings.Base
    properties
        HeteroskedasticityScale (1,1) double = 0.15

        Turningpoint (1,1) datetime
    end
end

