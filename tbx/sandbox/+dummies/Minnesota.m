
classdef Minnesota < settings.Base

    properties
        Lambda (1, 1) double = 0.1 % lambda1
        LagDecay (1, 1) double = 1 % lambda3
        ExogenousLambda (:, :) double = 100 % lambda4
        Autoregression (:, :) double = 0.8 % ar
        Exogenous (:, :) logical = false
    end

    methods
        % function dummiesYLX = generate(n, numX, order, ar, arvar, lambda1, lambda3, lambda4, priorexo)
        function dummiesYLX = generate(this, meta, initYXZ)
            % [numY, numL, numX, ~, order] = system.getDimensionsFromYLX(initYLX);
            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            numXI = numX + double(meta.HasIntercept);

            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numXI);
            end
            if isscalar(this.ExogenousLambda)
                this.ExogenousLambda = repmat(this.ExogenousLambda, numY, numXI);
            end
            if isscalar(this.Autoregression)
                this.Autoregression = repmat(this.Autoregression, numY, 1);
            end


            order = meta.Order;
            const = meta.HasIntercept;

            lambda1 = this.Lambda;
            lambda3 = this.LagDecay;
            lambda4 = this.ExogenousLambda; 
            ar = this.Autoregression;
            priorexo = this.Exogenous;

            [initY, ~, ~] = initYXZ{:};

            %variance from univariate OLS for priors
            arvar = bear.arloop(initY, const, order, numY);

            dummiesY = [
                diag(ar(1:numY, 1) .* arvar / lambda1)
                zeros(numY * (order-1), numY)
                (priorexo ./ (lambda1 .* lambda4))'
                diag(arvar)
            ];

            Jp = diag((1 : order) .^ lambda3);

            if numXI ~= 0
                dummiesLX = [
                    kron(Jp, diag(arvar/lambda1)), zeros(numY*order, numXI)
                    zeros(numXI, numY*order), diag(1./(lambda1*lambda4(1, :)))
                    zeros(numY, numY*order), zeros(numY, numXI)
                    ];
            else
                dummiesLX = [
                    kron(Jp, diag(arvar/lambda1))
                    zeros(numY, numY*order)
                    ];
            end
            
            dummiesYLX = {dummiesY, dummiesLX};
        end%
    end

end

