# Basic BVAR estimators

Estimators in alphabetical order



## `Flat` 

BVAR with flat prior

  prior =41 in BEAR5 with lambda1>999

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


## `IndNormalWishart` 

BVAR with indenpendent Normal-Wishart priors

  prior =31, 32 and 33

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
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;eye) |   prior = 31 and 32 respectively


## `Minnesota` 

BVAR with Minnesota prior

  prior =11 12 and 13 in BEAR5

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
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;diag;full) |   prior = 11, 12 and 13 respectively    


## `NormalDiffuse` 

prior =41 in BEAR5



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


## `NormalWishart` 

prior =21 and 22 in BEAR5



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
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;eye) |   prior =21  and 22 respectively


## `Ordinary` 





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

