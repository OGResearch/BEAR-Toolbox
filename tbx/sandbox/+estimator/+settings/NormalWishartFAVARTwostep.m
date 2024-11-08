
classdef (CaseInsensitiveProperties=true) NormalWishartFAVARTwostep < estimator.settings.Base

    properties
        LoadingVariance double = 1
        SigmaShape double = 3
        SigmaScale double = 1e-3
    end

end

