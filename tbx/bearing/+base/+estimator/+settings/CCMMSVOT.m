
classdef (CaseInsensitiveProperties=true) CCMMSVOT ...
    < base.estimator.settings.CCMMSVO

    properties
        % Lower bound of the uniform prior on degrees of freedom for inverse gamma (Q diagonal);
        QDoFLowerBound (1,1) double = 3 % lower bound of the uniform discrete prior distribution of 
        % the degrees of freedom in the inverse gamma distribution of the diagobnal elements in matrix Q
        % CCMM 3.2, originally Jacquier, Polson, and Rossi (2004)

        % Upper bound of the uniform prior on degrees of freedom for inverse gamma (Q diagonal);
        QDoFUpperBound (1,1) double = 40 % upper bound of the uniform discrete prior distribution of 
        % the degrees of freedom in the inverse gamma distribution of the diagonal elements in matrix Q
        % CCMM 3.2, originally Jacquier, Polson, and Rossi (2004)
    end

end

