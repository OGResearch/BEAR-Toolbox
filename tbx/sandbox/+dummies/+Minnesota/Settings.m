
classdef (CaseInsensitiveProperties=true) Settings < dummies.common.Settings

    properties
        LagDecay (1, 1) double = 1
        ExogenousLambda (1, 1) double = 100
        Autoregression (1, 1) double = 0.8
    end

    properties
        LegacyOptionMapping = [
            "Lambda", "lambda1"
            "LagDecay", "lambda3"
            "ExogenousLambda", "lambda4"
            "Autoregression", "ar"
        ]
    end

    methods
        function this = modifyDefaults(this)
            this.Lambda = 0.1;
        end%

        % function dummiesYLX = generate(n, numX, order, ar, arvar, lambda1, lambda3, lambda4, priorexo)
        function dummiesYLX = generate(this, initYLX)
            % [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            % [initY, ~, initX] = initYLX{:};

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

            % dummiesYLX = {dummiesY, dummiesL, dummiesX};
        end%
    end

end

