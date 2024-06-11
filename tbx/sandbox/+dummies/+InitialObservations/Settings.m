
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda7"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 1e-3;
        end%
    end

end

