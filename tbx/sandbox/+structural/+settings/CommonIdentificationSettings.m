
classdef ...
    (CaseInsensitiveProperties=true) ...
    CommonIdentificationSettings ...
    < structural.settings.AbstractSettings

    properties
        StdScale (1, :) double = 1
    end

    methods
        function this = modifyDefaults(this)
        end%
    end

end

