
classdef (CaseInsensitiveProperties=true) SumCoefficients < settings.Base

    properties
        Lambda (1, 1) double = 0.1
    end

    methods
        function dummiesYLX = generate(this, meta, initYXZ)
            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            order = meta.Order;
            lambda = this.Lambda;
            %
            [initY, ~, ~] = initYXZ{:};
            dummiesY = diag(mean(initY, 1, "omitNaN") / lambda);
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = zeros(numY, numX);
            %
            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

