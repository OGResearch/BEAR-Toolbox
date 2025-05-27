# Basic BVAR estimators

Estimators in alphabetical order



## `Flat` 

BVAR with flat prior

  prior =41 in BEAR5 with lambda1>999

### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `IndNormalWishart` 

BVAR with indenpendent Normal-Wishart priors

  prior =31, 32 and 33

### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye)| ar| text|   prior = 31 and 32 respectively
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `Minnesota` 

BVAR with Minnesota prior

  prior =11 12 and 13 in BEAR5

### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;diag;full)| ar| text|   prior = 11, 12 and 13 respectively    
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `NormalDiffuse` 

prior =41 in BEAR5



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `NormalWishart` 

prior =21 and 22 in BEAR5



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye)| ar| text|   prior =21  and 22 respectively
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `Ordinary` 





### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 

