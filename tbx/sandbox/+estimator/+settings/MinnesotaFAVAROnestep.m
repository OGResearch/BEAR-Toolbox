
classdef (CaseInsensitiveProperties=true) MinnesotaFAVAROnestep < estimator.settings.BaseFAVAR

    properties   
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "diag", "full"])} = "ar"
        LoadingVariance double = 1
        SigmaShape double = 3
        SigmaScale double = 1e-3
    end

end

