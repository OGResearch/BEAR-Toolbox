
classdef (CaseInsensitiveProperties=true) Settings < prior.common.Settings

    methods
        function this = modifyDefaults(this)
            this.Sigma = "ar";
        end%
    end

end

