
classdef (CaseInsensitiveProperties=true) IndNormalWishart < estimator.settings.Base

    properties     
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar" %prior = 31 and 32 respectively
    end

end

