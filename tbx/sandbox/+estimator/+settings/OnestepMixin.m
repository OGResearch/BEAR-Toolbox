classdef OnestepMixin < handle
    properties
        LoadingVariance double = 1
        SigmaShape double = 3
        SigmaScale double = 1e-3
    end
end
