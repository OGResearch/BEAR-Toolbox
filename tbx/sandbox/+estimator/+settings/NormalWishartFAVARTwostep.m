
classdef (CaseInsensitiveProperties=true) NormalWishartFAVARTwostep < estimator.settings.BaseFAVAR
    properties
            Sigma (1, 1) string {ismember(Sigma, [ "ar", "eye"])} = "ar"
    end
end

