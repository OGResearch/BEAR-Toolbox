
classdef (CaseInsensitiveProperties=true) NormalWishart < estimator.settings.Base

    methods
        function this = modifyDefaults(this)
            this.Sigma = "ar";
        end%
    end

end

