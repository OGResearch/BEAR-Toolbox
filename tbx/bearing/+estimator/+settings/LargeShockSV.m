
classdef (CaseInsensitiveProperties=true) LargeShockSV < estimator.settings.GenLargeShockSV

    properties
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


