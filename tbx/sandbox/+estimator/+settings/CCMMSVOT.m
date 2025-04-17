classdef (CaseInsensitiveProperties=true) CCMMSVOT < estimator.settings.CCMMSVO
    properties
        QDoFLowerBound (1,1) double = 3 
        QDoFUpperBound (1,1) double = 40 

    end
end

