
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties
        LegacyOptionMapping = [
            "Tightness", "lambda8"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 1;
        end%
    end

end

