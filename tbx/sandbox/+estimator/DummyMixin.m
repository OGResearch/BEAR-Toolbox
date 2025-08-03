
classdef (Abstract) DummyMixin < handle

    properties (Constant)
        CanHaveDummies = true
    end


    methods
        function initialize(this, meta, longYX, dummiesYLX)
            if this.BeenInitialized
                error("This estimator has already been initialized.");
            end
            this.initializeSampler(meta, longYX, dummiesYLX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%
    end

end

