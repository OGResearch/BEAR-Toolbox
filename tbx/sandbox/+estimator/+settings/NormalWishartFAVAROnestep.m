
classdef (CaseInsensitiveProperties=true) NormalWishartFAVAROnestep < estimator.settings.BaseFAVAR

    properties
        Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar"
        LoadingVariance double = 1
        SigmaShape double = 3
        SigmaScale double = 1e-3
    end

end

