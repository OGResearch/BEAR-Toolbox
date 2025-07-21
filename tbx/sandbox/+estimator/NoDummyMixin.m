classdef (Abstract) NoDummyMixin < handle


    methods(Abstract)
        initializeSampler(this, meta, longYX)
    end
    
    
    methods

        function initialize(this, meta, longYX)
            if this.BeenInitialized
                return
            end
            this.initializeSampler(meta, longYX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%

    end

end
