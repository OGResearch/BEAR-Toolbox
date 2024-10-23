
classdef Base < handle

    properties
        Settings
    end

    properties
        Sampler
        SamplerCounter (1, 1) uint64 = 0
        HistoryDrawer
        UnconditionalDrawer
        ConditionalDrawer
        IdentificationDrawer
    end

    properties (Dependent)
        ShortClassName
        BeenInitialized
    end

    properties (Abstract)
        CanHaveDummies
        CanHaveReducibles
        HasCrossUnits
    end

    methods (Abstract)
        initializeSampler(this, meta, longYXZ, dummiesYLX)
        createDrawers(this, meta)
    end

    methods
        function this = Base(meta, varargin)
            this.Settings = estimator.settings.(this.ShortClassName)(meta, varargin{:});
        end%

        function initialize(this, meta, longYXZ, dummiesYLX)
            if this.BeenInitialized
                error("Estimator has already been initialized");
            end
            this.initializeSampler(meta, longYXZ, dummiesYLX);
            this.createDrawers(meta);
        end%

        function name = get.ShortClassName(this)
            name = extractAfter(class(this), "estimator.");
        end%

        function out = get.BeenInitialized(this)
            out = ~isempty(this.Sampler);
        end%

        function checkConsistency(this, meta, dummies)
            this.checkCanHaveReducibles(meta);
            this.checkCanHaveDummies(dummies);
        end%

        function checkCanHaveReducibles(this, meta)
            if ~this.CanHaveReducibles && meta.HasReducibles
                error( ...
                    "Estimator %s does not allow for reduciables and factors" ...
                    , this.ShortClassName ...
                );
            end
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

