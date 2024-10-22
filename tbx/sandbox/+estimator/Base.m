
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
    end

    properties (Abstract)
        CanHaveDummies
        CanHaveReducibles
    end

    methods (Abstract)
        initializeSampler(this, meta, longYXZ, dummiesYLX)
        createDrawers(this, meta)
    end

    methods
        function this = Base(meta, varargin)
            this.Settings = estimator.settings.(this.ShortClassName)(meta, varargin{:});
        end%

        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler) && ~isempty(this.Drawer);
        end%

        function initialize(this, meta, longYXZ, dummiesYLX)
            this.initializeSampler(meta, longYXZ, dummiesYLX);
            this.createDrawers(meta);
        end%

        function name = get.ShortClassName(this)
            name = extractAfter(class(this), "estimator.");
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

