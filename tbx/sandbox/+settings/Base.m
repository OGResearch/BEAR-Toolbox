
% settings.Base  Base class for settings classes

classdef (CaseInsensitiveProperties=true) Base

    methods
        function this = Base(varargin)
            this = this.modifyDefaults();
            for i = 1:2:numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%
    end

    methods
        function this = modifyDefaults(this)
        end%
    end

end

