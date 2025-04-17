classdef (CaseInsensitiveProperties=true) CCMMSVO < estimator.settings.CCMMSV
    properties
        %mean outlier frequency: one in every X years
        OutlierFreq (1,1) double = 10 
        %scale of prior observations in years
        PriorObsYears (1,1) double = 10 

    end
end

