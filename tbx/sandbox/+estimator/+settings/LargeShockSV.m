
classdef (CaseInsensitiveProperties=true) LargeShockSV < estimator.settings.Base

    properties
        Mult0 double
        ScaleMult double  %scale on covariance scalingfactors' Pareto distribution
        ShapeMult double  %shape on covariance scalingfactors ' Pareto distribution

        MultAR0 (1,1) double {mustBeGreaterThanOrEqual(MultAR0, 0), mustBeLessThanOrEqual(MultAR0, 1)} = 0.5
        AlphaMultAR double %scaling factor's AR parameter's alpha value in beta  distribution
        BetaMultAR double %scaling factor's  AR parameter's beta value in beta  distribution

        Turningpoint (1,1) datetime

        Solver = @defaultSolver
    end

end

function y = defaultSolver(targetFunc, inits)

    optimopts = optimset(optimset("fminsearch"), ...
        "display", "iter", ...
        "tolX", 1e-16, ...
        "tolFun", 1e-16 ...
        );
    
    [y] = fminsearch(targetFunc, inits, optimopts);


end


