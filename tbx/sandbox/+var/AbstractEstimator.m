
classdef AbstractEstimator < handle

    properties
        PriorSettings
        Presampled (:, :) double = []
        Sampler
    end

    properties (Dependent)
        NumPresampled (1, 1) double
        NumParameters (1, 1) double
    end

    properties (SetAccess = protected)
        PresampledCounter (1, 1) uint32 = 0
    end

    methods (Abstract)
        varargout = initializeAdapter(this, varargin)
    end

    methods
        function num = get.NumPresampled(this)
            num = size(this.Presampled, 2);
        end%

        function numParameters = get.NumParameters(this)
            numParameters = size(this.Presampled, 1);
        end%

        function theta = nextPresampled(this, varargin)
            this.PresampledCounter = this.PresampledCounter + 1;
            if this.PresampledCounter > this.NumPresampled
                error("Presampled draws have been exhausted");
            end
            theta = this.Presampled(:, this.PresampledCounter+1);
        end%

        function resetPresampled(this)
            this.PresampledCounter = 0;
        end%

        function presampled = presample(this, numPresampled)
            presampled = cell(1, numPresampled);
            for i = 1 : numPresampled
                presampled{i} = this.Sampler();
            end
            presampled = horzcat(presampled{:});
            this.Presampled = presampled;
        end%

        function varargout = initialize(this, meta, dataTable, periods, options)
            arguments
                this
                meta (1, 1) var.Meta
                dataTable (:, :) timetable
                periods (1, :) datetime
                options.BurnIn (1, 1) double = NaN
            end
            YX = meta.getData(dataTable, periods);
            this.Sampler = this.initializeAdapter(meta, YX, burnin=options.BurnIn);
        end%
    end

end

