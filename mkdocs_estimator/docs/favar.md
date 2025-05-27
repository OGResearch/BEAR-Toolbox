# FAVAR estimators

Estimators in alphabetical order



## `BetaTVFAVAR` 

FAVAR verison of TV coefficients model, tvbvar=1 in BEAR5

  ...

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


## `CarrieroSVFAVAR` 

FAVAR version of SV for large models in BEAR5, stvol=3



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


## `CogleySargentSVFAVAR` 

FAVAR version of Standard SV model, in BEAR5,  stvol =1



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


## `FlatFAVAROnestep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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
`LoadingVariance` | Loading Variance| 1| numeric matrix|   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`SigmaScale` | Sigma scale| 0.001| numeric matrix|   b0
`SigmaShape` | Sigma shape| 3| numeric matrix|   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `FlatFAVARTwostep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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


## `GeneralTVFAVAR` 

FAVAR verison of General TV model tvbvar = 2



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


## `IndNormalWishartFAVAROnestep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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
`LoadingVariance` | Loading Variance| 1| numeric matrix|   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye)| ar| text|   prior = 31 and 32 respectively
`SigmaScale` | Sigma scale| 0.001| numeric matrix|   b0
`SigmaShape` | Sigma shape| 3| numeric matrix|   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `IndNormalWishartFAVARTwostep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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


## `MinnesotaFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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
`LoadingVariance` | Loading Variance| 1| numeric matrix|   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;diag;full)| ar| text|   prior = 11, 12 and 13 respectively    
`SigmaScale` | Sigma scale| 0.001| numeric matrix|   b0
`SigmaShape` | Sigma shape| 3| numeric matrix|   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `MinnesotaFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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


## `NormalDiffuseFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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
`LoadingVariance` | Loading Variance| 1| numeric matrix|   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`SigmaScale` | Sigma scale| 0.001| numeric matrix|   b0
`SigmaShape` | Sigma shape| 3| numeric matrix|   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `NormalDiffuseFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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


## `NormalWishartFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 inBEAR5

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
`LoadingVariance` | Loading Variance| 1| numeric matrix|   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye)| ar| text|   prior =21  and 22 respectively
`SigmaScale` | Sigma scale| 0.001| numeric matrix|   b0
`SigmaShape` | Sigma shape| 3| numeric matrix|   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `NormalWishartFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 in BEAR5

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


## `RandomInertiaSVFAVAR` 

FAVAR version of random inertia SV model, in BEAR5,  stvol =3



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

