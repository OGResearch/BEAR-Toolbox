# Basic BVAR estimators

Estimators in alphabetical order



## `Flat` 

BVAR with flat prior

  prior =41 in BEAR5 with lambda1>999

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


## `IndNormalWishart` 

BVAR with indenpendent Normal-Wishart priors

  prior =31, 32 and 33

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
`Sigma` | Method of calculating priors on covariance matrix (ar;eye) |   prior = 31 and 32 respectively
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `Minnesota` 

BVAR with Minnesota prior

  prior =11 12 and 13 in BEAR5

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
`Sigma` | Method of calculating priors on covariance matrix (ar;diag;full) |   prior = 11, 12 and 13 respectively    
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `NormalDiffuse` 

prior =41 in BEAR5



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


## `NormalWishart` 

prior =21 and 22 in BEAR5



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
`Sigma` | Method of calculating priors on covariance matrix (ar;eye) |   prior =21  and 22 respectively
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `Ordinary` 





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

