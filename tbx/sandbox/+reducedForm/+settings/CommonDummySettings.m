
classdef ...
    (CaseInsensitiveProperties=true) ...
    CommonDummySettings ...
    < reducedForm.settings.AbstractSettings

    properties
        Lambda1 double = 0.1
        Lambda2 double = 0.5
        Lambda3 double = 1
        Lambda4 double = 100
        Lambda5 double = 0.001
        Lambda6 double = 0.1
        Lambda7 double = 0.001
        Lambda8 double = 1
    end

    methods
        function this = modifyDefaults(this)
        end%
    end

end

