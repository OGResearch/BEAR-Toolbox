
classdef (CaseInsensitiveProperties=true) Minnesota < estimator.settings.Base

    properties
        % Method of calculating priors on covariance matrix (ar;diag;full)
        % prior = 11, 12 and 13 respectively    
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "diag", "full"])} = "ar" 
    end

end

