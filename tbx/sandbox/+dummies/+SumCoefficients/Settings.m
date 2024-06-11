
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties (Constant)
        Presence = true
    end

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda6"
            "Presence", "scoeff"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 0.1;
        end%
    end

end

