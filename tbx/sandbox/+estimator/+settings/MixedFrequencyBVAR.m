
classdef (CaseInsensitiveProperties=true) MixedFrequencyBVAR < estimator.settings.Base

    properties     
        % how many monhtly forecast to do in the original MF-BVAR code. Can be replaced in the future with Fsample_end-Fsample_start from BEAR
        KalmanFcastPeriod double = 7

        % hyperparameter: lambda1
        MfLambda1 double = 1.e-01;
        % hyperparameter: lambda2
        MfLambda2 double = 3.4;
        % hyperparameter: lambda3
        MfLambda3 double = 1;
        % hyperparameter: lambda4
        MfLambda4 double = 3.4;
        % hyperparameter: lambda5
        MfLambda5 double = 1.4763158e+01;
    end

end

