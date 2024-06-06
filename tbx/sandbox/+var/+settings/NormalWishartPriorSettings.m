
classdef ...
    (CaseInsensitiveProperties=true) ...
    NormalWishartPriorSettings ...
    < var.settings.CommonPriorSettings

    methods
        function this = modifyDefaults(this)
            this.Sigma = "ar";
        end%
    end

end

