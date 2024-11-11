
classdef (CaseInsensitiveProperties=true) MinnesotaFAVARTwostep < estimator.settings.BaseFAVAR

    properties   
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "diag", "full"])} = "ar"
    end

end

