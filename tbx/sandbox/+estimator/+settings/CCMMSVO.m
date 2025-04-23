classdef (CaseInsensitiveProperties=true) CCMMSVO < estimator.settings.CCMMSV
    properties
        OutlierFreq (1,1) double = 10 %mean outlier frequency: the value means one outlier in every X years, CCMM 3.2, originally Stock-Watson(2016)    
        PriorObsYears (1,1) double = 10 %controls the strength of the outlier prior, precision set to be consistent with X years’ worth of prior observations
        %CCMM 3.2, originally Stock-Watson(2016)   

    end
end

