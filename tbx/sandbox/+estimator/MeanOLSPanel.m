classdef MeanOLSPanel < estimator.Base

    properties
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
                stationary = 0;

                while stationary==0

                    beta=bhat+chol(bear.nspd(sigmahatb),'lower')*randn(q,1);

                    [stationary,~]=bear.checkstable(beta,n,p,k);

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

            function drawStruct = drawer(sampleStruct, horizon)
                %[
                beta = sampleStruct.bhat; % forecast is using mean OLS fixed parameters, no draws
                sigma = sampleStruct.sigma;

                B_temp = reshape(...
                            beta,...
                            numBRows,...
                            numEndog...
                            );

                sigma_temp = reshape(...
                            sigma,...
                            numEndog,...
                            numEndog...
                            );

                A_temp = B_temp(1:numARows,:);

                C_temp = B_temp(numARows+1:end,:);

                A = repmat(A_temp, [1, 1, numCountries]);
                C = repmat(C_temp, [1, 1, numCountries]);
                Sigma = repmat(sigma_temp, [1, 1, numCountries]);

                drawStruct = struct();
                drawStruct.A = repmat({A}, horizon, 1);
                drawStruct.C = repmat({C}, horizon, 1);
                drawStruct.Sigma = Sigma;
                %]
            end%

            function draw = unconditionalDrawer(sampleStruct, start, forecastHorizon)
                draw = drawer(sampleStruct, forecastHorizon);
                draw.Sigma = repmat({draw.Sigma}, forecastHorizon, 1);
            end%

            function draw = historyDrawer(sampleStruct)
                draw = drawer(sampleStruct, estimationHorizon);
                draw.Sigma = repmat({draw.Sigma}, estimationHorizon, 1);
            end%

            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.IdentificationDrawer = @(sample) drawer(sample, identificationHorizon);

            %]
        end%
    end

end
