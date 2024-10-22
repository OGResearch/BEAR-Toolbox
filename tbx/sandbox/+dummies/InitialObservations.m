
classdef (CaseInsensitiveProperties=true) InitialObservations < settings.Base

    properties
        Lambda (1, 1) double = 1e-3
    end

    methods

        function dummiesYLX = generate(this, meta, longYXZ)
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY, longX, ~] = longYXZ{:};
            initY = longY(1:order, :);
            initX = longX(1:order, :);
            initX = system.addInterceptWhenNeeded(initX, meta.HasIntercept);
            %
            dummiesY = mean(initY, 1, "omitNaN") / lambda;
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = mean(initX, "omitnan") / lambda;
            dummiesLX = [dummiesL, dummiesX];
            %
            dummiesYLX = {dummiesY, dummiesLX};
        end%

    end

end

