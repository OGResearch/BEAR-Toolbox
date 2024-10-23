
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
            numPages = size(initY, 3);
            %
            dummiesY = mean(initY, 1, "omitNaN") / lambda;
            %
            dummiesL = cell(1, numPages);
            for i = 1 : numPages
                dummiesL{i} = kron(ones(1, order), dummiesY(:, :, i));
            end
            dummiesL = cat(3, dummiesL{:});
            %
            dummiesX = mean(initX, "omitnan") / lambda;
            dummiesX = repmat(dummiesX, 1, 1, numPages);
            %
            dummiesYLX = {dummiesY, [dummiesL, dummyX]};
        end%

    end

end

