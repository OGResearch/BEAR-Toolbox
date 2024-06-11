
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties (Constant)
        Present = true
    end


    properties
        LegacyOptionMapping = [
            "Tightness", "lambda7"
            "Present", "iobs"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Tightness = 1e-3;
        end%
    end

end

