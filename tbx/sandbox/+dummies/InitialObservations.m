
classdef (CaseInsensitiveProperties=true) InitialObservations < dummies.Common

    methods
        function this = modifyDefaults(this)
            this.Lambda = 1e-3;
        end%

        function dummiesYLX  = generate(this, initYLX)
            [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            [initY, ~, initX] = initYLX{:};
            lambda = this.Lambda;
            dummiesY = mean(initY, 1, "omitNaN") / lambda;
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = mean(initX, "omitnan") / lambda;
            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

