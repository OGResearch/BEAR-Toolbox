
classdef (CaseInsensitiveProperties=true) Minnesota < estimator.settings.Base

    properties     
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "diag", "full"])} = "ar" %prior = 11 12 and 13 respectively
    end

end

