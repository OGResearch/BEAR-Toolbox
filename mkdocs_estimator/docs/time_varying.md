# Time-varying BVAR estimators

Estimators in alphabetical order



## `BetaTV` 

Time-varying Bayesian VAR model

  Second line
  Third line

### Settings 
Name | Description | BEAR5 reference
------|-----------|-
`Autoregression` | Prior on first-order autoregression |   ar
`BlockExogenous` | Block exogeneity flag |   bex
`Burnin` | Number of burn-in draws |   Bu
`Exogenous` | Priors on exogenous variables flag |   priorexogenous
`Lambda1` | Overal tightness of priors |   lambda1
`Lambda2` | Variable weighting |   lambda2
`Lambda3` | Leg decay |   lambda3
`Lambda4` | Exogenous variable tightness |   lambda4
`Lambda5` | Block exogeneity shrinkage |   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `GeneralTV` 

general time varying in bear5, tvbvar=2



### Settings 
Name | Description | BEAR5 reference
------|-----------|-
`Autoregression` | Prior on first-order autoregression |   ar
`BlockExogenous` | Block exogeneity flag |   bex
`Burnin` | Number of burn-in draws |   Bu
`Exogenous` | Priors on exogenous variables flag |   priorexogenous
`HeteroskedasticityAutoRegression` | AR coefficient on residual variance |   gamma
`HeteroskedasticityScale` | IG scale on residual variance |   delta0
`HeteroskedasticityShape` | IG shape on residual variance |   alpha0
`Lambda1` | Overal tightness of priors |   lambda1
`Lambda2` | Variable weighting |   lambda2
`Lambda3` | Leg decay |   lambda3
`Lambda4` | Exogenous variable tightness |   lambda4
`Lambda5` | Block exogeneity shrinkage |   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 

