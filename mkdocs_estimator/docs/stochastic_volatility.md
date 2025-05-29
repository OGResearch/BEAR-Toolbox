# Stochastic volatility estimators

Estimators in alphabetical order



## `CarrieroSV` 

SV for large models in BEAR5, stvol=3

  ...

### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`HeteroskedasticityAutoRegression` | AR coefficient on residual variance| 1| numeric matrix|   gamma
`HeteroskedasticityScale` | IG scale on residual variance| 0.001| numeric matrix|   delta0
`HeteroskedasticityShape` | IG shape on residual variance| 0.001| numeric matrix|   alpha0
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `CogleySargentSV` 

Standard model, in BEAR5,  stvol =1



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`HeteroskedasticityAutoRegression` | AR coefficient on residual variance| 1| numeric matrix|   gamma
`HeteroskedasticityScale` | IG scale on residual variance| 0.001| numeric matrix|   delta0
`HeteroskedasticityShape` | IG shape on residual variance| 0.001| numeric matrix|   alpha0
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `RandomInertiaSV` 

SV model with random inertia, in BEAR5 stvol=2



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`HeteroskedasticityAutoRegression` | AR coefficient on residual variance| 1| numeric matrix|   gamma
`HeteroskedasticityAutoRegressionVariance` | Prior variance of inertia| 0.01| numeric matrix|   zeta0
`HeteroskedasticityScale` | IG scale on residual variance| 0.001| numeric matrix|   delta0
`HeteroskedasticityShape` | IG shape on residual variance| 0.001| numeric matrix|   alpha0
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 

