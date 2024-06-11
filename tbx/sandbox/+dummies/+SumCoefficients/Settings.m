
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda6"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 0.1;
        end%
    end

end

