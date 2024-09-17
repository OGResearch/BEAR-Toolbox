
classdef (CaseInsensitiveProperties=true) Minnesota < estimator.settings.Base

    properties     
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "diag", "full"])} = "ar"
    end

end

