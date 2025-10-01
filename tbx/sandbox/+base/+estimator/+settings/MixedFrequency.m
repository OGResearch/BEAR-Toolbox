
classdef (CaseInsensitiveProperties=true) MixedFrequency ...
    < base.estimator.Settings

    properties
        % Numeber of periods to forecast in a Kalman filter
        % H
        KalmanFcastPeriod double = 7
        % how many monhtly forecast to do in the original MF-BVAR code. Can be replaced in the future with Fsample_end-Fsample_start from BEAR

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

