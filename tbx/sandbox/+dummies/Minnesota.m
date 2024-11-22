
classdef (CaseInsensitiveProperties=true) Minnesota < settings.Base

    properties
        Lambda (1, 1) double = 0.1 % lambda1, overall tightness
        LagDecay (1, 1) double = 1 % lambda3, leg decay
        ExogenousLambda (:, :) double = 100 % lambda4, exogenous tightness
        Autoregression (:, :) double = 0.8 % ar
        Exogenous (:, :) logical = false %priorexogenous
    end


    methods

        function dummiesYLX = generate(this, meta, longYXZ)

            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;

            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numX);
            end
            if isscalar(this.ExogenousLambda)
                this.ExogenousLambda = repmat(this.ExogenousLambda, numY, numX);
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

            [longY, ~, ~] = longYXZ{:};

            %variance from univariate OLS for priors
            arvar = bear.arloop(longY, const, order, numY);

            dummiesY = [
                diag(ar(1:numY, 1) .* arvar / lambda1)
                zeros(numY * (order-1), numY)
                (priorexo ./ (lambda1 .* lambda4))'
                diag(arvar)
            ];

            Jp = diag((1 : order) .^ lambda3);

            if numX ~= 0
                dummiesLX = [
                    kron(Jp, diag(arvar/lambda1)), zeros(numY*order, numX)
                    zeros(numX, numY*order), diag(1./(lambda1*lambda4(1, :)))
                    zeros(numY, numY*order), zeros(numY, numX)
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

