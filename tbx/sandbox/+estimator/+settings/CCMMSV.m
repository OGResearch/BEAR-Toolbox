classdef (CaseInsensitiveProperties=true) CCMMSV < estimator.settings.Base
    properties
        HeteroskedasticityScale (1,1) double = 0.15 %Controls the final prior scaling param in the IW distribution of the covariance matrix of
        % the error term of the RW of the heteroscedasticity parameter. The
        % final scalig parameter is this value  multiplied by the degress
        % of freedom which is set as a function of variables

        Turningpoint (1,1) datetime %Used for setting the prior B, as the OLS for getting the prior mean B is estimated only up to this point
    end
end

