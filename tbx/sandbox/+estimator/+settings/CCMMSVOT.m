classdef (CaseInsensitiveProperties=true) CCMMSVOT < estimator.settings.CCMMSVO
    properties
        QDiagonalLowerBound (1,1) double = 3 
        QDiagonalUpperBound (1,1) double = 40 

    end
end

