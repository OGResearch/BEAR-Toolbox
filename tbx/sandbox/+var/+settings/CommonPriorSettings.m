
classdef ...
    (CaseInsensitiveProperties=true) ...
    CommonPriorSettings ...
    < var.settings.AbstractSettings

    properties
        Burnin (1, 1) double = 0

        Exogenous (1, 1) logical = false

        Autoregressive (1, 1) double = 0.8

        Lambda1 double = 0.1
        Lambda2 double = 0.5
        Lambda3 double = 1
        Lambda4 double = 100
        Lambda5 double = 0.001
        Lambda6 double = 0.1
        Lambda7 double = 0.001
        Lambda8 double = 1

        Sigma (1, 1) string {ismember(Sigma, ["eye", "ar", "var"])} = "eye"
    end

    methods
        function this = modifyDefaults(this)
        end%
    end

end

