
classdef ...
    (CaseInsensitiveProperties=true) ...
    CommonPriorSettings ...
    < var.settings.AbstractPriorSettings

    properties
        Exogenous (1, 1) logical = false

        Autoregressive (1, 1) double = 0.8

        Lambda1 (1, 1) double = 0.1
        Lambda2 (1, 1) double = 0.5
        Lambda3 (1, 1) double = 1
        Lambda4 (1, 1) double = 100
        Lambda5 (1, 1) double = 0.001
        Lambda6 (1, 1) double = 0.1
        Lambda7 (1, 1) double = 0.001
        Lambda8 (1, 1) double = 1

        Sigma (1, 1) string {ismember(Sigma, ["eye", "ar", "var"])} = "eye"
    end

    methods
        function this = modifyDefaults(this)
        end%
    end

end

