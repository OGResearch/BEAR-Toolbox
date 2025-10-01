
classdef (Abstract) Estimator ...
    < handle

    properties (Abstract)
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


    properties (Dependent)
        ShortClassName
    end


    properties (Abstract, Constant)
        Description
        Category
        CanHaveDummies
        HasCrossUnits
        CanBeIdentified
        HasCrossUnitVariationInBeta
        HasCrossUnitVariationInSigma
    end


    properties (SetAccess=protected)
        BeenInitialized (1, 1) logical = false
    end


    methods (Abstract)
        initializeSampler(this, varargin)
        createDrawers(this, varargin)
    end


    methods
        function this = Estimator(varargin)
            name = this.ShortClassName;
            this.Settings = panel.estimator.settings.(name)(varargin{:});
        end%

        function initialize(this, meta, longYX, dummiesYLX)
            arguments
                this
                meta (1, 1) panel.Meta
                longYX (1, 2) cell
                dummiesYLX (1, 2) cell
            end
            %
            if this.BeenInitialized
                warning("The estimator has already been initialized; skipping.");
                return
            end
            %
            if this.CanHaveDummies
                this.initializeSampler(meta, longYX, dummiesYLX);
            else
                this.initializeSampler(meta, longYX);
            end
            this.createDrawers(meta);
        end%

        function deinitialize(this)
            this.BeenInitialized = false;
            this.SampleCounter = uint64(0);
            this.Sampler = [];
            this.HistoryDrawer = [];
            this.UnconditionalDrawer = [];
            this.ConditionalDrawer = [];
            this.IdentificationDrawer = [];
        end%

        function name = get.ShortClassName(this)
            name = extractAfter(class(this), "estimator.");
        end%
    end

end

