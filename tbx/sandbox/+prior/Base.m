
classdef Base < handle

    properties
        Settings
        Sampler = []
        SamplerCounter (1, 1) uint64 = 0
    end

    methods (Abstract)
        varargout = initialize(this, varargin)
    end

    methods
        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler);
        end%
    end

end

