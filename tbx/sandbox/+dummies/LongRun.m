
classdef (CaseInsensitiveProperties=true) LongRun < settings.Base

    properties
        Lambda (1, 1) double = 1 %lambda8 in BEAR5, long run prior tightness
        Constraints (:, :)
    end

    methods

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


        function dummiesYLX = generate(this, meta, longYXZ)
            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY, ~, ~] = longYXZ{:};
            initY = longY(1:order, :);
            %
            H = this.Constraints;
            invH = inv(H);
            meanY = transpose(mean(initY, 1));
            dummiesY = [];
            for ii = 1 : numY
                add = (H(ii, :) * meanY / lambda) * invH(:, ii);
                dummiesY = [dummiesY, add];
            end
            dummiesL = repmat(dummiesY, 1, order);
            dummiesX = zeros(numY, numX);
            dummiesLX = [dummiesL, dummiesX];
            %
            dummiesYLX = {dummiesY, dummiesLX};
        end%
    end

end

