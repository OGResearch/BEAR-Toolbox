# Mixed frequency BVAR estimators

Estimators in alphabetical order



## `MixedFrequencyBVAR` 

Mixed-frequency BVAR



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`KalmanFcastPeriod` | Numeber of periods to forecast in a Kalman filter| 7| numeric matrix|   H
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`MfLambda1` | hyperparameter: lambda1| 0.1| numeric matrix| 
`MfLambda2` | hyperparameter: lambda2| 3.4| numeric matrix| 
`MfLambda3` | hyperparameter: lambda3| 1| numeric matrix| 
`MfLambda4` | hyperparameter: lambda4| 3.4| numeric matrix| 
`MfLambda5` | hyperparameter: lambda5| 14.7632| numeric matrix| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 

