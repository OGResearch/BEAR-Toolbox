
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


    properties (Abstract, Constant)
        Description
        Category
        CanHaveDummies
        HasCrossUnits
        CanBeIdentified
    end


    methods (Abstract)
        initialize(this, varargin)
        initializeSampler(this, varargin)
        createDrawers(this, varargin)
    end


    methods
        function this = Base(varargin)
            this.Settings = estimator.settings.(this.ShortClassName)(varargin{:});
        end%


        function name = get.ShortClassName(this)
            name = extractAfter(class(this), "estimator.");
        end%
    end

end

