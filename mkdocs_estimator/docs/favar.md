# FAVAR estimators

Estimators in alphabetical order



## `BetaTVFAVAR` 

FAVAR verison of TV coefficients model, tvbvar=1 in BEAR5

  ...

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


## `CarrieroSVFAVAR` 

FAVAR version of SV for large models in BEAR5, stvol=3



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


## `CogleySargentSVFAVAR` 

FAVAR version of Standard SV model, in BEAR5,  stvol =1



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


## `FlatFAVAROnestep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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
`LoadingVariance` | `1` | Loading Variance |   L0
`SigmaScale` | `0.001` | Sigma scale |   b0
`SigmaShape` | `3` | Sigma shape |   a0


## `FlatFAVARTwostep` 

FAVAR version of prior =41 within lambda> 999 BEAR5



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


## `GeneralTVFAVAR` 

FAVAR verison of General TV model tvbvar = 2



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


## `IndNormalWishartFAVAROnestep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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
`LoadingVariance` | `1` | Loading Variance |   L0
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;eye) |   prior = 31 and 32 respectively
`SigmaScale` | `0.001` | Sigma scale |   b0
`SigmaShape` | `3` | Sigma shape |   a0


## `IndNormalWishartFAVARTwostep` 

BFAVAR with Individual Normal-Wishart prior

  FAVAR version of prior =31 32 BEAR5

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


## `MinnesotaFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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
`LoadingVariance` | `1` | Loading Variance |   L0
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;diag;full) |   prior = 11, 12 and 13 respectively    
`SigmaScale` | `0.001` | Sigma scale |   b0
`SigmaShape` | `3` | Sigma shape |   a0


## `MinnesotaFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =11 12 and 13 BEAR5

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


## `NormalDiffuseFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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
`LoadingVariance` | `1` | Loading Variance |   L0
`SigmaScale` | `0.001` | Sigma scale |   b0
`SigmaShape` | `3` | Sigma shape |   a0


## `NormalDiffuseFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =41 BEAR5

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


## `NormalWishartFAVAROnestep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 inBEAR5

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
`LoadingVariance` | `1` | Loading Variance |   L0
`Sigma` | `"ar"` | Method of calculating priors on covariance matrix (ar;eye) |   prior =21  and 22 respectively
`SigmaScale` | `0.001` | Sigma scale |   b0
`SigmaShape` | `3` | Sigma shape |   a0


## `NormalWishartFAVARTwostep` 

BFAVAR with Normal-Wishart prior

  FAVAR version of prior =21 22 in BEAR5

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


## `RandomInertiaSVFAVAR` 

FAVAR version of random inertia SV model, in BEAR5,  stvol =3



### Settings 
Name | Default | Description | BEAR5 reference
------|-------:|-----------|-
`Autoregression` | `0.8` | Prior on first-order autoregression |   ar
`BlockExogenous` | `false` | Block exogeneity flag |   bex
`Burnin` | `0` | Number of burn-in draws |  Bu
`Exogenous` | `false` | Priors on exogenous variables flag |  priorexogenous
`HeteroskedasticityAutoRegression` | `1` | AR coefficient on residual variance |   gamma
`HeteroskedasticityAutoRegressionVariance` | `0.01` | Prior variance of inertia |   zeta0
`HeteroskedasticityScale` | `0.001` | IG scale on residual variance |   delta0
`HeteroskedasticityShape` | `0.001` | IG shape on residual variance |   alpha0
`Lambda1` | `0.1` | Overal tightness of priors |   lambda1
`Lambda2` | `0.5` | Variable weighting |   lambda2
`Lambda3` | `1` | Leg decay |   lambda3
`Lambda4` | `100` | Exogenous variable tightness |   lambda4
`Lambda5` | `0.001` | Block exogeneity shrinkage |   lambda5

