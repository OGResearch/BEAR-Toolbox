# Time-varying BVAR estimators

Estimators in alphabetical order



## `BetaTV` 

Time-varying Bayesian VAR model

  Second line
  Third line

### Settings 
Name | Default | Description | BEAR5 reference
------|-------:|-----------|-
`Autoregression` | `0.8` | Prior on first-order autoregression |   ar
`BlockExogenous` | `false` | Block exogeneity flag |   bex
`Burnin` | `0` | Number of burn-in draws |  Bu
`Exogenous` | `false` | Priors on exogenous variables flag |  priorexogenous
`Lambda1` | `0.1` | Overal tightness of priors |   lambda1
`Lambda2` | `0.5` | Variable weighting |   lambda2
`Lambda3` | `1` | Leg decay |   lambda3
`Lambda4` | `100` | Exogenous variable tightness |   lambda4
`Lambda5` | `0.001` | Block exogeneity shrinkage |   lambda5


## `GeneralTV` 

general time varying in bear5, tvbvar=2



### Settings 
Name | Default | Description | BEAR5 reference
------|-------:|-----------|-
`Autoregression` | `0.8` | Prior on first-order autoregression |   ar
`BlockExogenous` | `false` | Block exogeneity flag |   bex
`Burnin` | `0` | Number of burn-in draws |  Bu
`Exogenous` | `false` | Priors on exogenous variables flag |  priorexogenous
`HeteroskedasticityAutoRegression` | `1` | AR coefficient on residual variance |   gamma
`HeteroskedasticityScale` | `0.001` | IG scale on residual variance |   delta0
`HeteroskedasticityShape` | `0.001` | IG shape on residual variance |   alpha0
`Lambda1` | `0.1` | Overal tightness of priors |   lambda1
`Lambda2` | `0.5` | Variable weighting |   lambda2
`Lambda3` | `1` | Leg decay |   lambda3
`Lambda4` | `100` | Exogenous variable tightness |   lambda4
`Lambda5` | `0.001` | Block exogeneity shrinkage |   lambda5

