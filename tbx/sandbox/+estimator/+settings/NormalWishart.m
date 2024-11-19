
classdef (CaseInsensitiveProperties=true) NormalWishart < estimator.settings.Base

    properties
        % Sigma  Method of calculating priors on covariance matrix
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar"
    end

end

