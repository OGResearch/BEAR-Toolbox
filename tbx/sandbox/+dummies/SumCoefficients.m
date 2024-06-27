
classdef (CaseInsensitiveProperties=true) SumCoefficients < dummies.Common

    methods
        function this = modifyDefaults(this)
            this.Lambda = 0.1;
        end%

        function dummiesYLX = generate(this, initYLX)
            [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            [initY, ~, ~] = initYLX{:};
            lambda = this.Lambda;
            dummiesY = diag(mean(initY, 1, "omitNaN") / lambda);
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = zeros(numY, numX);
            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

