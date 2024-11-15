classdef NormalWishartPanel < estimator.Base

    properties
        DescriptionUX = "Normal-Wishart Panel BVAR"

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
            numCountries = meta.NumUnits;

            ar = this.Settings.Autoregression;
            lambda1 = this.Settings.Lambda1;
            lambda3 = this.Settings.Lambda3;
            lambda4 = this.Settings.Lambda4;
            priorexo = this.Settings.Exogenous;

            % reshape input endogenous matrix
            % longY = reshape(longY,size(longY,1),numEndog,numCountries);

            % compute preliminary elements
            [X, ~, Y, ~, N, n, m, p, T, k, q]=bear.panel2prelim(longY,longX,const,numLags,cell(numCountries,1));

            % obtain prior elements (from a standard normal-Wishart)
            [B0, beta0, phi0, S0, alpha0]=bear.panel2prior(N,n,m,p,T,k,q,longY,ar,lambda1,lambda3,lambda4,priorexo);

            % obtain posterior distribution parameters
            [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,N*T,k);

            function sampleStruct = sampler()

                % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
                B=bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);

                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma=bear.iwdraw(Sbar,alphabar);

                sampleStruct = struct();
                sampleStruct.beta = B(:);
                sampleStruct.sigma = sigma(:);

            end

            this.Sampler = @sampler;

            %]
        end

        % TODO: Split into betaDrawer and sigmaDrawer
        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numARows = numEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numBRows = numARows + numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            % TODO: Split into betaDrawer and sigmaDrawer
            function drawStruct = drawer(sampleStruct, horizon)
                beta = sampleStruct.beta;
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
            end%


            function draw = unconditionalDrawer(sampleStruct, start, forecastHorizon)
                draw = drawer(sampleStruct, forecastHorizon);
                draw.Sigma = repmat({draw.Sigma}, forecastHorizon, 1);
            end%

            function draw = historyDrawer(sampleStruct)
                draw = drawer(sampleStruct, estimationHorizon);
                draw.Sigma = repmat({draw.Sigma}, estimationHorizon, 1);
            end%

            function draw = conditionalDrawer(sample)
                draw = struct();
                % TODO: implement
            end%

            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.IdentificationDrawer = @(sample) drawer(sample, identificationHorizon);
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%
    end
end

