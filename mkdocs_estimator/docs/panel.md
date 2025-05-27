# Panel estimators

Estimators in alphabetical order



## `DynamicCrossPanel` 





### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`A0` | IG shape on factor variance| 1000| numeric scalar|   a0
`Alpha0` | IG shape on residual variance| 1000| numeric scalar|   alpha0
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`B0` | IG scale on factor variance| 1| numeric scalar|   b0
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Delta0` | IG scale on residual variance| 1| numeric scalar|   delta0
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Gamma` | AR coefficient on residual variance| 0.85| numeric scalar|   gamma
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Psi` | Variance of Metropolis draw| 0.1| numeric scalar|   psi
`Rho` | AR coefficient on factors| 0.75| numeric scalar|   rho
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `HierarchicalPanel` 





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
`S0` | IG shape on overall tightness| 0.001| numeric scalar|   s0
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 
`V0` | IG scale on overall tightness| 0.001| numeric scalar|   v0


## `MeanOLSPanel` 

Mean OLS Panel BVAR



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


## `NormalWishartPanel` 





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


## `StaticCrossPanel` 





### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`Alpha0` | IG shape on residual variance| 1000| numeric scalar|   alpha0
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Delta0` | IG scale on residual variance| 1| numeric scalar|   delta0
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 


## `ZellnerHongPanel` 





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

