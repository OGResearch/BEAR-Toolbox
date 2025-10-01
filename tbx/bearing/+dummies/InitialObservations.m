
classdef (CaseInsensitiveProperties=true) InitialObservations < dummies.Base

    properties
        Lambda (1, 1) double = 1e-3 %lambda7 in BEAR7, initial observation tightness
    end


    methods

        function this = InitialObservations(this, options)
            arguments
                this (1, 1) InitialObservations
                options.Lambda (1, 1) double = 1e-3
            end
            this.Lambda = options.Lambda;
        end%


        function dummiesYLX = generate(this, meta, longYX)
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY, longX] = longYX{:};
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
            dummiesYLX = {dummiesY, [dummiesL, dummiesX]};
        end%
    end

end

