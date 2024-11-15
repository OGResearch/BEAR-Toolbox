
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

            function sampleStruct = sampler()

                % draw a random vector beta from its distribution
                % if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
                while true
                    beta = bhat + chol(bear.nspd(sigmahatb),'lower')*randn(q,1);
                    [stationary,~] = bear.checkstable(beta,n,p,k);
                    if stationary
                        break
                    end
                end

                sampleStruct = struct();
                sampleStruct.beta = beta;
                sampleStruct.sigma = sigmahat;
                sampleStruct.bhat = bhat;

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

            function drawStruct = betaDrawer(sampleStruct, horizon)
                %[
                beta = sampleStruct.bhat; % forecast is using mean OLS fixed parameters, no draws

                B_temp = reshape(...
                            beta,...
                            numBRows,...
                            numEndog...
                            );

                A_temp = B_temp(1:numARows,:);

                C_temp = B_temp(numARows+1:end,:);

                A = repmat(A_temp, [1, 1, numCountries]);
                C = repmat(C_temp, [1, 1, numCountries]);

                drawStruct = struct();
                drawStruct.A = repmat({A}, horizon, 1);
                drawStruct.C = repmat({C}, horizon, 1);
                %]
            end%

            function drawStruct = sigmaDrawer(sampleStruct, horizon)
                %[
                sigma = sampleStruct.sigma;

                sigma_temp = reshape(...
                            sigma,...
                            numEndog,...
                            numEndog...
                            );
                Sigma = repmat(sigma_temp, [1, 1, numCountries]);

                drawStruct = struct();
                drawStruct.Sigma = Sigma;
                %]
            end%

            function draw = unconditionalDrawer(sampleStruct, start, forecastHorizon)
                %[
                draw = betaDrawer(sampleStruct, forecastHorizon);
                drawS = sigmaDrawer(sampleStruct, forecastHorizon);
                draw.Sigma = repmat({drawS.Sigma}, forecastHorizon, 1);
                %]
            end%

            function draw = historyDrawer(sampleStruct)
                draw = betaDrawer(sampleStruct, estimationHorizon);
                drawS = sigmaDrawer(sampleStruct, estimationHorizon);
                draw.Sigma = repmat({drawS.Sigma}, estimationHorizon, 1);
            end%

            function draw = conditionalDrawer(sampleStruct, startingIndex, forecastHorizon )

                beta = sampleStruct.beta;
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
