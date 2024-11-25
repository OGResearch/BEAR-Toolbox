
classdef (CaseInsensitiveProperties=true) NormalWishart < estimator.settings.Base

    properties
        % Sigma  Method of calculating priors on covariance matrix
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar" %prior =21  and 22 in BEAR5
    end

end

