
classdef Common < settings.Base

    properties
        Lambda = NaN
    end

    methods (Abstract)
        varargout = generate(this, varargin)
    end

end

