
classdef (CaseInsensitiveProperties=true) GenLargeShockSV < estimator.settings.Base

    properties
        Mult0 double
        ScaleMult double  %scale on covariance scaling factors' Pareto distribution
        ShapeMult double  %shape on covariance scaling factors ' Pareto distribution
        PropStdMult double %scaling factors proposal std

        MultAR0 (1,1) double {mustBeGreaterThanOrEqual(MultAR0, 0), mustBeLessThanOrEqual(MultAR0, 1)} = 0.5
        AlphaMultAR (1,1) double %scaling factor's AR parameter's alpha value in beta  distribution
        BetaMultAR (1,1) double %scaling factor's  AR parameter's beta value in beta  distribution
        PropStdAR (1,1) double %scaling factors's  AR parameter's proposal std

        Turningpoint (1,1) datetime
    end

end



