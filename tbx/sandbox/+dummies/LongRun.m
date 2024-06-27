
classdef (CaseInsensitiveProperties=true) LongRun < dummies.Common

    properties 
        Constraints (:, :)
    end

    methods
        function this = modifyDefaults(this)
            this.Lambda = 1;
        end%

        function this = postprocessSettings(this)
            if istable(this.Constraints)
                this.Constraints = this.Constraints{:,:};
            end
            this.Constraints = double(this.Constraints);
            rankH = rank(this.Constraints);
            sizeH = size(this.Constraints, 1);
            if rankH < sizeH
                error("Long-run prior matrix is singular: rank=%g, size=%g.", rankH, sizeH);
            end
        end%

        function dummiesYLX = generate(this, initYLX)
            [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            [initY, ~, ~] = initYLX{:};
            H = this.Constraints;
            invH = inv(H);
            meanY = transpose(mean(initY, 1));
            lambda = this.Lambda;
            dummiesY = [];
            for ii = 1 : numY
                add = (H(ii, :) * meanY / lambda) * invH(:, ii);
                dummiesY = [dummiesY, add];
            end
            dummiesL = repmat(dummiesY, 1, order);
            dummiesX = zeros(numY, numX);
            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

