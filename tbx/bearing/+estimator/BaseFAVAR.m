
classdef (Abstract) BaseFAVAR ...
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
            % TODO
            % * introduce a OneStep property for subclasses of BaseFAVAR
            % * remove this method, and merge within initialize() above

            % if contains(lower(this.ShortClassName), "onestep")
            %     onestep = true;
            % else
            %     onestep = false;
            % end

            this.FAVAR = estimator.initializeFAVAR( ...
                meta, ...
                longYX, ...
                longZ, ...
                this.OneStep ...
            );
        end%
    end

end

