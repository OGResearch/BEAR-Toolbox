
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties (Constant)
        Presence (1, 1) double = 51
    end

    properties
        LagDecay (1, 1) double = 1
        ExogenousTightness (1, 1) double = 100
        Autoregression (1, 1) double = 0.8
    end

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda1"
            "LagDecay", "lambda3"
            "ExogenousTightness", "lambda4"
            "Autoregression", "ar"
            "Presence", "prior"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 0.1;
        end%
    end

end

