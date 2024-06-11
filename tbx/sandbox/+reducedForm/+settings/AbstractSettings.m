
classdef ...
    (Abstract, CaseInsensitiveProperties=true) ...
    AbstractSettings

    methods
        function this = AbstractSettings(varargin)
            this = this.modifyDefaults();
            for i = 1:2:numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%
    end

    methods (Abstract)
        varargout = modifyDefaults(varargin)
    end

end

