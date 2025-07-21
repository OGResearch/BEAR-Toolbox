
classdef (Abstract) BaseFAVAR < estimator.Base

    properties
        FAVAR
    end

    methods
        function this = BaseFAVAR(varargin)
            this@estimator.Base(varargin{:})
        end%

        function initialize(this, meta, longYX, longZ)
            if this.BeenInitialized
                return
            end
            this.initializeFAVAR(meta, longYX, longZ);
            this.initializeSampler(meta, longYX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%


        function initializeFAVAR(this, meta, longYX, longZ)

            if contains(lower(this.ShortClassName), "onestep")
                onestep = true;
            else
                onestep = false;
            end

            this.FAVAR = estimator.initializeFAVAR(meta, longYX, longZ, onestep);
        end


    end

end

