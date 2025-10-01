
classdef (CaseInsensitiveProperties=true) Custom < base.identifier.settings.Base

    properties
        DiscardReducedFormAfter (1, 1) double = Inf
        Exact (1, :) string
        Verifiable (1, :) string
    end

end

