
classdef Base < handle

    properties
        Settings
    end

    properties
        Preallocator
        Sampler
        SamplerCounter (1, 1) uint64 = 0
        EstimationSpan (1, :) datetime
    end

    methods (Abstract)
        initializeSampler(this, meta, YLX)
    end

    methods
        function this = Base(varargin)
            className = extractAfter(class(this), "estimator.");
            this.Settings = estimator.settings.(className)(varargin{:});
        end%


        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler) && ~isempty(this.Preallocator);
        end%


        function initialize(this, YLX)
            this.initializePreallocator(YLX);
            this.initializeSampler(YLX);
        end%


        function initializePreallocator(this, YLX)
            [Y, L, X] = YLX{:};
            numY = size(Y, 2);
            numL = size(L, 2);
            numX = size(X, 2);
            numT = size(Y, 1);
            numBeta = numY * (numL + numX);
            numSigma = numY * numY;
            if this.Settings.TimeVariant
                numPeriods = numT;
            else
                numPeriods = 1;
            end
            function sample = preallocator(numDraws)
                sample = {
                    nan(numPeriods, numDraws, numBeta), ...
                    nan(numPeriods, numDraws, numSigma), ...
                };
            end%
            this.Preallocator = @preallocator;
        end%

        function finalizeFromMeta(this, meta)
            numY = meta.NumEndogenousColumns;
            numX = meta.NumExogenousColumns;;
            this.Settings.HasConstant = meta.HasConstant;
            if isscalar(this.Settings.Exogenous)
                this.Settings.Exogenous = repmat(this.Settings.Exogenous, numY, numX);
            end
            if isscalar(this.Settings.Lambda4)
                this.Settings.Lambda4 = repmat(this.Settings.Lambda4, numY, numX);
            end
            if isscalar(this.Settings.Autoregression)
                this.Settings.Autoregression = repmat(this.Settings.Autoregression, numY, 1);
            end
        end%
    end

end

