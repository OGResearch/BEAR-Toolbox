
classdef (CaseInsensitiveProperties=true) NormalDiffuse < estimator.settings.Base

    properties     
        Sigma (1, 1) string {ismember(Sigma, ["none"])} = "none"
    end

end

