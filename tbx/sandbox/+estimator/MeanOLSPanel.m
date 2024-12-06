
classdef MeanOLSPanel < estimator.Base

    properties
        DescriptionUX = "Mean OLS Panel BVAR"

        CanHaveDummies = false
        CanHaveReducibles = false
        HasCrossUnits = false
    end


    methods

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
            [X, Y, N, n, m, p, T, k, q]=bear.panel1prelim(longY,longX,const,numLags);

            % obtain the estimates for the model
            [bhat, sigmahatb, sigmahat]=bear.panel1estimates(X,Y,N,n,q,k,T);

            function sample = sampler()

                % draw a random vector beta from its distribution
                % if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
                while true
                    beta = bhat + chol(bear.nspd(sigmahatb),'lower')*randn(q,1);
                    [stationary,~] = bear.checkstable(beta,n,p,k);
                    if stationary
                        break
                    end
                end

                sample = struct();
                sample.beta = beta;
                sample.sigma = sigmahat;
                sample.bhat = bhat;

            end

            this.Sampler = @sampler;

            %]
        end


        function createDrawers(this, meta)
            %[

            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numARows = numEndog*meta.Order;
            numBRows = numARows+meta.NumExogenousNames+double(meta.HasIntercept);
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            function draw = betaDrawer(sample, horizon)
                %[
                beta = sample.bhat; % forecast is using mean OLS fixed parameters, no draws

                B_temp = reshape(...
                            beta,...
                            numBRows,...
                            numEndog...
                            );

                A_temp = B_temp(1:numARows,:);

                C_temp = B_temp(numARows+1:end,:);

                A = repmat(A_temp, [1, 1, numCountries]);
                C = repmat(C_temp, [1, 1, numCountries]);

                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                %]
            end%

            function draw = sigmaDrawer(sample, horizon)
                %[
                sigma = sample.sigma;

                sigma_temp = reshape(...
                            sigma,...
                            numEndog,...
                            numEndog...
                            );
                Sigma = repmat(sigma_temp, [1, 1, numCountries]);

                draw = struct();
                draw.Sigma = Sigma;
                %]
            end%

            function draw = drawer(sample, horizon)
                %[
                draw = betaDrawer(sample, estimationHorizon);
                drawS = sigmaDrawer(sample, estimationHorizon);
                draw.Sigma = drawS.Sigma;
                %]
            end%

            function draw = unconditionalDrawer(sample, start, forecastHorizon)
                %[
                draw = betaDrawer(sample, forecastHorizon);
                drawS = sigmaDrawer(sample, forecastHorizon);
                draw.Sigma = repmat({drawS.Sigma}, forecastHorizon, 1);
                %]
            end%

            function draw = historyDrawer(sample)
                draw = betaDrawer(sample, estimationHorizon);
                drawS = sigmaDrawer(sample, estimationHorizon);
                draw.Sigma = repmat({drawS.Sigma}, estimationHorizon, 1);
            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )

                beta = sample.beta;
                draw.beta = repmat({beta}, forecastHorizon, 1);

            end%

            this.IdentificationDrawer = @(sample) drawer(sample, identificationHorizon);
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%
    end

end
