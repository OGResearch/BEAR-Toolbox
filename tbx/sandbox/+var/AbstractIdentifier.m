
classdef AbstractIdentifier < handle

    properties
        IdentificationSettings
        Sampler = []
        SamplerCounter (1,1) uint32 = 0
    end

    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end

    methods
        function varargout = initialize(this, meta, dataTable, periods)
            arguments
                this
                meta (1, 1) var.Meta
                dataTable (:, :) timetable
                periods (1, :) datetime
            end
            YX = meta.getDataYX(dataTable, periods);
            this.initializeSampler(meta, YX);
        end%

        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler);
        end%
    end

end

