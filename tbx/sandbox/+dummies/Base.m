
classdef (CaseInsensitiveProperties=true) Base < handle

    methods (Abstract)
        varargout = generate(this, varargin)
    end

end

