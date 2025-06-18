classdef (CaseInsensitiveProperties=true) Threshold < estimator.settings.Base
    properties
        % Controls the prior variance of the threshold
        VarThreshold (1,1) double = 10 

        % Controls the maxium delay allowed for the threshold variable for regime identification
        MaxDelay (1,1) {mustBePositive, mustBeInteger} = 4 

        % Controls the proposal standard deviation of the MH algoruthm of the threshold draws
        ThresholdPropStd (1,1) double = sqrt(0.001)
    end
end

