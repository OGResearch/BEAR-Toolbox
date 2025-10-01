
classdef Estimator ...
    < base.Estimator

    methods
        function this = Estimator(varargin)
            name = this.ShortClassName;
            this.Settings = meanadj.estimator.settings.(name)(varargin{:});
        end%
    end

end

