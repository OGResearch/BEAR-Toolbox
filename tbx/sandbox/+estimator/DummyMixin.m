classdef (Abstract) DummyMixin < handle


    methods(Abstract)
        initializeSampler(this, meta, longYX, dummiesYLX)
    end
    
    
    
    methods

        function initialize(this, meta, longYX, dummiesYLX)
            if this.BeenInitialized
                return
            end
            this.initializeSampler(meta, longYX, dummiesYLX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%
        
    end

end
