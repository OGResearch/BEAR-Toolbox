
classdef (Abstract) Base < handle

    properties
        Settings
    end

    properties
        Sampler
        SampleCounter (1, 1) uint64 = 0
        HistoryDrawer
        UnconditionalDrawer
        ConditionalDrawer
        IdentificationDrawer
    end

    properties
        BeenInitialized (1, 1) logical = false
        HasCrossUnitVariationInBeta (1, 1) logical = false
        HasCrossUnitVariationInSigma (1, 1) logical = false
        HasTimeVariationInBeta (1, 1) logical = false
    end

    properties (Dependent)
        ShortClassName
    end

    properties (Abstract)
        CanHaveDummies
        HasCrossUnits
        Category 
        CanBeIdentified 
    end

    methods (Abstract)
        initializeSampler(this, meta, longYX, dummiesYLX)
        createDrawers(this, meta)
    end

    methods
        function this = Base(varargin)
            this.Settings = estimator.settings.(this.ShortClassName)(varargin{:});
        end%

        function initialize(this, meta, longYX, dummiesYLX)
            if this.BeenInitialized
                return
            end
            this.initializeSampler(meta, longYX, dummiesYLX);
            this.createDrawers(meta);
            this.BeenInitialized = true;
        end%

        function name = get.ShortClassName(this)
            name = extractAfter(class(this), "estimator.");
        end%

        function checkConsistency(this, meta, dummies)
            this.checkCanHaveDummies(dummies);
        end%

        function checkCanHaveDummies(this, dummies)
            if ~this.CanHaveDummies && ~isempty(dummies)
                error( ...
                    "Estimator %s does not allow for dummy observations" ...
                    , this.ShortClassName ...
                );
            end
        end%

    end

end

