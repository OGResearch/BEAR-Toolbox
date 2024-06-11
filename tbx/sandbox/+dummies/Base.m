
classdef Base

    properties
        Settings (1, 1)
    end

    methods
        function this = Base(varargin)
            className = split(string(class(this)), ".");
            className = className(end);
            this.Settings = dummies.(className).Settings(varargin{:});
        end%
    end

end

