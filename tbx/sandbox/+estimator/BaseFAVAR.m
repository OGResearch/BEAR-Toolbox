
classdef (Abstract) BaseFAVAR < estimator.Base

    properties
        FAVAR
    end

    methods
        function this = BaseFAVAR(varargin)
            this@estimator.Base(varargin{:})
        end%

        function initialize(this, meta, longYXZ, dummiesYLX)
            if this.BeenInitialized
                return
            end
            this.initializeFAVAR(meta, longYXZ);
            this.initializeSampler(meta, longYXZ);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%


        function initializeFAVAR(this, meta, longYXZ)

            if contains(lower(this.ShortClassName),"onestep")
                onestep = true;
            else
                onestep = false;
            end

            this.FAVAR = estimator.initializeFAVAR(meta, longYXZ, onestep);
        end


    end

end

