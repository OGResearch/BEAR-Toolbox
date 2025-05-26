# FAVAR estimators

Estimators in alphabetical order



## `BetaTVFAVAR` 

FAVAR verison of TV coefficients model, tvbvar=1 in BEAR5

  ...

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


## `CarrieroSVFAVAR` 

FAVAR version of SV for large models in BEAR5, stvol=3



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


## `CogleySargentSVFAVAR` 

FAVAR version of Standard SV model, in BEAR5,  stvol =1



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


## `FlatFAVAROnestep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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
`LoadingVariance` | Loading Variance |   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`SigmaScale` | Sigma scale |   b0
`SigmaShape` | Sigma shape |   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `FlatFAVARTwostep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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


## `GeneralTVFAVAR` 

FAVAR verison of General TV model tvbvar = 2



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


## `IndNormalWishartFAVAROnestep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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
`LoadingVariance` | Loading Variance |   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye) |   prior = 31 and 32 respectively
`SigmaScale` | Sigma scale |   b0
`SigmaShape` | Sigma shape |   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `IndNormalWishartFAVARTwostep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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


## `MinnesotaFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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
`LoadingVariance` | Loading Variance |   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`Sigma` | Method of calculating priors on covariance matrix (ar;diag;full) |   prior = 11, 12 and 13 respectively    
`SigmaScale` | Sigma scale |   b0
`SigmaShape` | Sigma shape |   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `MinnesotaFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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


## `NormalDiffuseFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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
`LoadingVariance` | Loading Variance |   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`SigmaScale` | Sigma scale |   b0
`SigmaShape` | Sigma shape |   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `NormalDiffuseFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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


## `NormalWishartFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 inBEAR5

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
`LoadingVariance` | Loading Variance |   L0
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`Sigma` | Method of calculating priors on covariance matrix (ar;eye) |   prior =21  and 22 respectively
`SigmaScale` | Sigma scale |   b0
`SigmaShape` | Sigma shape |   a0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 


## `NormalWishartFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 in BEAR5

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


## `RandomInertiaSVFAVAR` 

FAVAR version of random inertia SV model, in BEAR5,  stvol =3



### Settings 
Name | Description | BEAR5 reference
------|-----------|-
`Autoregression` | Prior on first-order autoregression |   ar
`BlockExogenous` | Block exogeneity flag |   bex
`Burnin` | Number of burn-in draws |   Bu
`Exogenous` | Priors on exogenous variables flag |   priorexogenous
`HeteroskedasticityAutoRegression` | AR coefficient on residual variance |   gamma
`HeteroskedasticityAutoRegressionVariance` | Prior variance of inertia |   zeta0
`HeteroskedasticityScale` | IG scale on residual variance |   delta0
`HeteroskedasticityShape` | IG shape on residual variance |   alpha0
`Lambda1` | Overal tightness of priors |   lambda1
`Lambda2` | Variable weighting |   lambda2
`Lambda3` | Leg decay |   lambda3
`Lambda4` | Exogenous variable tightness |   lambda4
`Lambda5` | Block exogeneity shrinkage |   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts | 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude | 

