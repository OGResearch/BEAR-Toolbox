# Mixed frequency BVAR estimators

Estimators in alphabetical order



## `MixedFrequencyBVAR` 

Mixed-frequency BVAR



### Settings 
Name | Default | Description | BEAR5 reference
------|-------:|-----------|-
`Autoregression` | `0.8` | Prior on first-order autoregression |   ar
`BlockExogenous` | `false` | Block exogeneity flag |   bex
`Burnin` | `0` | Number of burn-in draws |  Bu
`Exogenous` | `false` | Priors on exogenous variables flag |  priorexogenous
`KalmanFcastPeriod` | `7` | Numeber of periods to forecast in a Kalman filter |   H
`Lambda1` | `0.1` | Overal tightness of priors |   lambda1
`Lambda2` | `0.5` | Variable weighting |   lambda2
`Lambda3` | `1` | Leg decay |   lambda3
`Lambda4` | `100` | Exogenous variable tightness |   lambda4
`Lambda5` | `0.001` | Block exogeneity shrinkage |   lambda5
`MfLambda1` | `0.1` | hyperparameter: lambda1 | 
`MfLambda2` | `3.4` | hyperparameter: lambda2 | 
`MfLambda3` | `1` | hyperparameter: lambda3 | 
`MfLambda4` | `3.4` | hyperparameter: lambda4 | 
`MfLambda5` | `14.7632` | hyperparameter: lambda5 | 

