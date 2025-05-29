# Large scale BVAR estimators

Estimators in alphabetical order



## `GenLargeShockSV` 

SV for large models in BEAR5, stvol=3



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`AlphaMultAR` | Scaling factor's AR parameter's alpha value in beta| | numeric scalar| 
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BetaMultAR` | Scaling factor's  AR parameter's beta value in beta| | numeric scalar| 
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Mult0` | Initial mean of scaling factors| | numeric matrix| 
`MultAR0` | Scaling factor's AR parameter's initial mean| 0.5| numeric scalar| 
`PropStdAR` | Scaling factors's  AR parameter's proposal std| | numeric scalar| 
`PropStdMult` | Scaling factors proposal std| | numeric matrix| 
`ScaleMult` | Scale on covariance scaling factors' Pareto distribution| | numeric matrix| 
`ShapeMult` | Shape on covariance scaling factors ' Pareto distribution| | numeric matrix| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 
`Turningpoint` | | | undefined| 


## `LargeShockSV` 

SV for large models in BEAR5, stvol=3



### Settings 
Name | Description | Default value | Type | BEAR5 reference
---|----|----|---|---
`AlphaMultAR` | Scaling factor's AR parameter's alpha value in beta| | numeric scalar| 
`Autoregression` | Prior on first-order autoregression| 0.8| numeric vector|   ar
`BetaMultAR` | Scaling factor's  AR parameter's beta value in beta| | numeric scalar| 
`BlockExogenous` | Block exogeneity flag| false| logical matrix|   bex
`Burnin` | Number of burn-in draws| 0| numeric scalar|   Bu
`Exogenous` | Priors on exogenous variables flag| false| logical matrix|   priorexogenous
`Lambda1` | Overall tightness of priors| 0.1| numeric matrix|   lambda1
`Lambda2` | Variable weighting| 0.5| numeric matrix|   lambda2
`Lambda3` | Leg decay| 1| numeric matrix|   lambda3
`Lambda4` | Exogenous variable tightness| 100| numeric matrix|   lambda4
`Lambda5` | Block exogeneity shrinkage| 0.001| numeric matrix|   lambda5
`MaxNumUnstableAttempts` | Maximum number of unstable sampling attempts| 1000| numeric scalar| 
`Mult0` | Initial mean of scaling factors| | numeric matrix| 
`MultAR0` | Scaling factor's AR parameter's initial mean| 0.5| numeric scalar| 
`PropStdAR` | Scaling factors's  AR parameter's proposal std| | numeric scalar| 
`PropStdMult` | Scaling factors proposal std| | numeric matrix| 
`ScaleMult` | Scale on covariance scaling factors' Pareto distribution| | numeric matrix| 
`ShapeMult` | Shape on covariance scaling factors ' Pareto distribution| | numeric matrix| 
`Solver` | | function handle| text matrix| 
`StabilityThreshold` | Threshold for maximum eigenvalue magnitude| Inf| numeric scalar| 
`Turningpoint` | | | undefined| 

