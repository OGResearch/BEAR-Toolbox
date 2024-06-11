
classdef ...
    (CaseInsensitiveProperties=true) ...
    NormalWishartPriorSettings ...
    < reducedForm.settings.CommonPriorSettings

    methods
        function this = modifyDefaults(this)
            this.Sigma = "ar";
        end%
    end

end

