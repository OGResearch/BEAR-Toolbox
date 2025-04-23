classdef (CaseInsensitiveProperties=true) CCMMSVOT < estimator.settings.CCMMSVO
    properties
        QDoFLowerBound (1,1) double = 3 % lower bound of the uniform discrete prior distribution of 
        % the degrees of freedom in the inverse gamma distribution of the diagobnal elements in matrix Q
        % CCMM 3.2, originally Jacquier, Polson, and Rossi (2004)

        QDoFUpperBound (1,1) double = 40 % upper bound of the uniform discrete prior distribution of 
        % the degrees of freedom in the inverse gamma distribution of the diagonal elements in matrix Q
        % CCMM 3.2, originally Jacquier, Polson, and Rossi (2004)
    end
end

