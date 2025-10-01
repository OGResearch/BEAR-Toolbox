
classdef (Abstract) NoDummyMixin < handle

    properties (Constant)
        CanHaveDummies = false
    end


    methods
        function initialize(this, meta, longYX, ~)
            if this.BeenInitialized
                error("This estimator has already been initialized.");
            end
            this.initializeSampler(meta, longYX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%
    end

end

