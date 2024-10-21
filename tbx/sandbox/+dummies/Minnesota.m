
classdef Minnesota < settings.Base

    properties
        Lambda (1, 1) double = 0.1 % lambda1
        LagDecay (1, 1) double = 1 % lambda3
        ExogenousLambda (1, 1) double = 100 % lambda4
        Autoregression (1, 1) double = 0.8 % ar
    end

    methods
        % function dummiesYLX = generate(n, numX, order, ar, arvar, lambda1, lambda3, lambda4, priorexo)
        function dummiesYLX = generate(this, meta, initYXZ)
            % [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            order = meta.Order;
            %
            [initY, initX] = initYXZ{:};
            %
            % dummiesY = [
            %     diag(ar(1:numY, 1).*arvar/lambda1)
            %     zeros(numY*(order-1), numY)
            %     (priorexo./(lambda1.*lambda4))'
            %     diag(arvar)
            % ];

            % Jp = diag((1 : order) .^ this.LagDecay);

            % Xm = [
            %     kron(Jp, diag(arvar/lambda1)), zeros(numY*order, numX)
            %     zeros(numX, numY*order), diag(1./(lambda1*lambda4(1, :)))
            %     zeros(numY, numY*order), zeros(numY, numX)
            % ]; % error if numX is equal to zero

            dummiesY = zeros(0, numY);
            dummiesL = zeros(0, numY*order);
            dummiesX = zeros(0, numX);

            dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

