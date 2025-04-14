classdef LargeShockSV < estimator.Base
    %SV for large models in BEAR5, stvol=3

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

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1; %Large shock
            opt.lambda3 = this.Settings.Lambda3; %Lag-decay

            opt.ar = this.Settings.Autoregression;

            opt.mult0 = this.Settings.Mult0; %initial mean of scaling factors
            opt.scaleTheta = this.Settings.ScaleMult; %scale on covariance scalingfactors' Pareto distribution
            opt.shapeTheta = this.Settings.ShapeMult; %shape on covariance scalingfactors ' Pareto distribution

            opt.AR0 = this.Settings.MultAR0; %scaling factor's AR parameter's initial mean
            opt.alphaAR = this.Settings.AlphaMultAR; %scaling factor's AR parameter's alpha value in beta  distribution
            opt.betaAR = this.Settings.BetaMultAR; %scaling factor's  AR parameter's beta value in beta  distribution

            opt.TP = this.Settings.Turningpoint;

            solver = this.Settings.Solver;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, estimLength, numBRows, ~] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            T0LS = find(meta.LongSpan == opt.TP);
            T0SS = find(meta.ShortSpan == opt.TP);

            varScale = bear.arloop(longY(1:T0LS-1,:), opt.const, 1, numEn);
            prior = largeshocksv.get_MH_Prior(opt, numEn, numBRows, varScale);

            %Get initial theta as a vector maximizing the posterior
            targFun = @(x) -largeshocksv.postlmpdf(x, opt, prior, Y, LX, T0SS);

            inits =  [opt.mult0, opt.AR0];
            % [initTheta] = fminsearch(targFun, hypers, optimopts);

            [initTheta] = solver(targFun, inits);

            H = largeshocksv.DERIVESTsuite.hessian(@(x)targFun(x), initTheta);

            %getting proposals for the MH algo
            propCholCov = chol(inv(H), "lower");
            propScale   = 8.5e-2;

            scaledPropCholCov = propScale*propCholCov;
            propGen = @()scaledPropCholCov * randn(numel(initTheta), 1);

            prevAccepted      = initTheta;
            prevLogTargetPDF  = -targFun(prevAccepted);

            function sample  =  sampler()

                accepted = 0;
                while ~accepted
                    %Getting sampled theta from MH
                    proposal = propGen()';
                    cand = prevAccepted + proposal;
                    candLogTargetPDF = -targFun(cand);
                    alpha = min(1, exp(candLogTargetPDF - prevLogTargetPDF));
                    accepted = rand() < alpha;
                end

                sample.theta = cand;
                prevAccepted = cand;
                prevLogTargetPDF = candLogTargetPDF;

                %Get conditional Sigma and B
                [scY, scX] = largeshocksv.scaleData(Y, LX, T0SS, sample.theta);
                posterior = largeshocksv.get_NIW_Posterior(prior, scY, scX);
    
                %Sigma
                nVars = size(posterior.cholInvScaleSigma, 1);
                X = randn(nVars, posterior.dfSigma);
                A = posterior.cholInvScaleSigma * X;
                AAt = A*A';
    
                sample.Sigma_avg   = AAt \ eye(nVars);
    
                % B
                nPars = numel(posterior.meanB);
                nParsEq = nPars / nVars;
                X = randn(nParsEq, nVars);
    
                sample.B = posterior.meanB + posterior.cholCovB * X * chol(sample.Sigma_avg);
                sample.sf = largeshocksv.scaleFactor(sample.theta, estimLength, T0SS);
    
    
                for zz = 1:estimLength
                    sample.Sigma_t{zz, 1} = sample.sf(zz)^2*sample.Sigma_avg;
                end
    
                this.SampleCounter = this.SampleCounter + 1;

        end

        this.Sampler = @sampler;

        %]
    end%


    function createDrawers(this, meta)
        %[

        %sizes
        numEn = meta.NumEndogenousNames;
        numARows = numEn * meta.Order;
        estimationHorizon = numel(meta.ShortSpan);
        identificationHorizon = meta.IdentificationHorizon;


        function draw = unconditionalDrawer(sample, startingIndex, forecastHorizon)

            B = sample.B;
            A = B(1:numARows, :);
            C = B(numARows + 1:end, :);
            draw.A = repmat({A}, forecastHorizon, 1);
            draw.C = repmat({C}, forecastHorizon, 1);
            draw.Sigma = cell(forecastHorizon, 1);

            AR = sample.theta(end);
            sf = sample.sf(startingIndex:end);
            sf_periods = numel(sf);

            for rng = sf_periods + 1 : forecastHorizon
                sf(rng) = 1 + (sf(rng-1) - 1) * AR;
            end

            % then generate Sigma forecasts recursively
            for jj = 1:forecastHorizon
                % recover sigma_t and draw the residuals
                draw.Sigma{jj, 1}(:, :) = sf(jj)^2*sample.Sigma_avg;
            end
        end

        function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )

            beta = sample.B{:};
            draw.beta = repmat({beta}, forecastHorizon, 1);

        end%


        function draw = identificationDrawer(sample)

            horizon = identificationHorizon;

            B = sample.B;
            A = B(1:numARows, :);
            C = B(numARows + 1:end, :);

            draw.A = repmat({A}, horizon, 1);
            draw.C = repmat({C}, horizon, 1);
            draw.Sigma = sample.Sigma_avg;

        end

        function draw = historyDrawer(sample)

            % reshape it to obtain B
            B = sample.B;
            A = B(1:numARows, :);
            C = B(numARows + 1:end, :);
            draw.A = repmat({A}, estimationHorizon, 1);
            draw.C = repmat({C}, estimationHorizon, 1);

            for jj = 1:estimationHorizon
                draw.Sigma{jj,1}(:, :) = sample.Sigma_t{jj, 1};
            end

        end%

        this.UnconditionalDrawer = @unconditionalDrawer;
        this.ConditionalDrawer = @conditionalDrawer;
        this.IdentificationDrawer = @identificationDrawer;
        this.HistoryDrawer = @historyDrawer;

        %]
    end%

end

end