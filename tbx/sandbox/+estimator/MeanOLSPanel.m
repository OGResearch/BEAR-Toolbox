
classdef MeanOLSPanel < estimator.Base
% Mean OLS Panel BVAR

    methods (Static)
        function info = getModelReference()
            info.category = "panel";
        end
    end

    properties
        DescriptionUX = "Mean OLS Panel BVAR"

        CanHaveDummies = false
        
        HasCrossUnits = false

        Category = "Panel BVAR estimators"

        %Struct identification
        CanBeIdentified = true
    end


    methods

        function this = MeanOLSPanel(varargin)
            this = this@estimator.Base(varargin{:});
            this.HasCrossUnitVariationInBeta = true;
            this.HasCrossUnitVariationInSigma = true;
        end%


        function initializeSampler(this, meta, longYXZ, dummiesYLX)
            %[
            arguments
                this
                meta (1, 1) model.Meta
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = longYXZ{:};

            const = meta.HasIntercept;
            numLags = meta.Order;

            % compute preliminary elements
            [X, Y, N, n, m, p, T, k, q] = bear.panel1prelim(longY,longX,const,numLags);

            % obtain the estimates for the model
            [bhat, sigmahatb, sigmahat]=bear.panel1estimates(X,Y,N,n,q,k,T);
            factor = chol(bear.nspd(sigmahatb), "lower");

            function sample = sampler()
                % draw a random vector beta from its distribution
                % if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
                while true
                    beta = bhat + factor * randn(q, 1);
                    [stationary,~] = bear.checkstable(beta,n,p,k);
                    if stationary
                        break
                    end
                end

                sample = struct();
                sample.beta = beta;
                sample.sigma = sigmahat;
                sample.bhat = bhat;
            end%

            this.Sampler = @sampler;
            %]
        end


        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numRowsA = numEndog*meta.Order;
            numRowsB = numRowsA + meta.NumExogenousNames + double(meta.HasIntercept);
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);

            function [A, C] = betaDrawer(sample, horizon)
                % beta = reshape(sample.bhat, numRowsB, numEndog);
                beta = reshape(sample.beta, numRowsB, numEndog);
                A = beta(1:numRowsA,:);
                C = beta(numRowsA+1:end,:);
                A = repmat(A, [1, 1, numCountries]);
                C = repmat(C, [1, 1, numCountries]);
                if horizon > 0
                    A = wrap(A, horizon);
                    C = wrap(C, horizon);
                end
            end%

            function sigma = sigmaDrawer(sample, horizon)
                sigma = reshape(sample.sigma, numEndog, numEndog);
                sigma = repmat(sigma, [1, 1, numCountries]);
                if horizon > 0
                    sigma = wrap(sigma, horizon);
                end
            end%

            function draw = identificationDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, identificationHorizon);
                draw.Sigma = sigmaDrawer(sample, 0);
            end%

            function draw = unconditionalDrawer(sample, start, forecastHorizon)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, forecastHorizon);
                draw.Sigma = sigmaDrawer(sample, forecastHorizon);
            end%

            function draw = historyDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, estimationHorizon);
                draw.Sigma = sigmaDrawer(sample, estimationHorizon);
            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon)
                draw = struct();
                draw.beta = wrap(sample.beta, forecastHorizon);
            end%

            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%
    end

end
