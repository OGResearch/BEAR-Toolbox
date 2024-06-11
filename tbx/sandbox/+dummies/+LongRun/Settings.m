
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties (Constant)
        Presence = true
    end

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda8"
            "Presence", "lrp"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 1;
        end%
    end

end

