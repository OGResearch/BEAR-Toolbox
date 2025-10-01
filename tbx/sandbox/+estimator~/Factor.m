
classdef (Abstract) Factor ...
    < estimator.Base

    properties (Abstract, Constant)
        OneStepFactors (1, 1) logical
    end


    properties
        FAVAR
    end


    properties
        CanHaveDummies = false
    end


    methods
        function this = Factor(varargin)
            this@estimator.Base(varargin{:})
        end%

        function initialize(this, meta, longYX, longZ)
            if this.BeenInitialized
                warning("This estimator has already been initialized; skipping initialization.");
                return
            end
            this.initializeFAVAR(meta, longYX, longZ);
            this.initializeSampler(meta, longYX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%

        function initializeFAVAR(this, meta, longYX, longZ)
            this.FAVAR = estimator.initializeFAVAR( ...
                meta, ...
                longYX, ...
                longZ, ...
                this.OneStep ...
            );
        end%
    end

end

