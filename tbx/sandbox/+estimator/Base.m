
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
        initializeSampler(this, meta, YXZ)
    end

    methods
        function this = Base(meta, varargin)
            className = extractAfter(class(this), "estimator.");
            this.Settings = estimator.settings.(className)(meta, varargin{:});
        end%


        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler) && ~isempty(this.Preallocator);
        end%


        function initialize(this, meta, YXZ)
            this.initializePreallocator(meta, YXZ);
            this.initializeSampler(YXZ);
        end%


        function initializePreallocator(this, meta, YXZ)
            [Y, ~, ~] = YXZ{:};
            numT = size(Y, 1) - meta.Order;
            numY = meta.NumEndogenousColumns;
            numL = meta.NumEndogenousColumns * meta.Order;
            numX = meta.NumExogenousColumns;

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
    end

end

