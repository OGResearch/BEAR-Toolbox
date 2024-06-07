
classdef AbstractEstimator < handle

    properties
        PriorSettings
        Sampler
        SamplerCounter (1, 1) uint64 = 0
    end

    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end

    methods
        function varargout = initialize(this, meta, dataTable, periods, options)
            arguments
                this
                meta (1, 1) var.Meta
                dataTable (:, :) timetable
                periods (1, :) datetime
                options.Burnin (1, 1) double = NaN
            end
            YX = meta.getDataYX(dataTable, periods);
            this.initializeSampler(meta, YX, burnin=options.Burnin);
        end%
    end

end

