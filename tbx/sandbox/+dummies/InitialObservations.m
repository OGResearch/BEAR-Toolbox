
classdef (CaseInsensitiveProperties=true) InitialObservations < settings.Base

    properties
        Lambda (1, 1) double = 1e-3
    end

    methods
        function dummiesYLX  = generate(this, meta, initYXZ)
            order = meta.Order;
            lambda = this.Lambda;
            %
            [initY, initX, ~] = initYXZ{:};
            dummiesY = mean(initY, 1, "omitNaN") / lambda;
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = mean(initX, "omitnan") / lambda;
            %
            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

