
classdef (CaseInsensitiveProperties=true) NormalWishart < estimator.settings.Base

    properties     
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar"
    end

end

