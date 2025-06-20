classdef StaticCrossPanel < estimator.Base

    methods (Static)
        function info = getModelReference()
            info.category = "panel";
        end
    end
    
    properties
        DescriptionUX = "Static Cross-Sectional Panel BVAR"

        CanHaveDummies = false
        
        HasCrossUnits = true

        Category = "Panel BVAR estimators"

        %Struct identification
        CanBeIdentified = true        
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
            numEndog = meta.NumEndogenousConcepts;

            alpha0 = this.Settings.Alpha0;
            delta0 = this.Settings.Delta0;
            Bu = this.Settings.Burnin;

            % reshape input endogenous matrix
            longY = reshape(longY,size(longY,1),numEndog,numCountries);

            % compute preliminary elements
            [Ymat, Xmat, numCountries, numEndog, numExog, numLags, T, k, q, h]=bear.panel5prelim(longY,longX,const,numLags);

            % obtain prior elements
            [~, ~, ~, ~, ~, d, ~, ~, ~, ~, ~, Xi, Y, y, Xtilde, Xdot, theta0, Theta0]=bear.panel5prior(numCountries,numEndog,numLags,numExog,k,q,h,T,Ymat,Xmat);

            % start preparing for a sampler
            % compute first  preliminary elements
            % compute alphabar
            alphabar=numCountries*numEndog*T+alpha0;
            % compute the inverse Theta0
            invTheta0=sparse(diag(1./diag(Theta0)));
            % initiate the Gibbs sampler

            % step 1: compute initial values
            % initial value for theta (use OLS values)
            theta=(Xtilde*Xtilde')\(Xtilde*y);

            % initial value for sigmatilde (use residuals form OLS values)
            eps=y-Xtilde'*theta;
            eps=reshape(eps,T,numCountries*numEndog);
            sigmatilde=eps'*eps;

            % initiate value for the sigma, the scaling term for the errors
            sig=1;

            % initiate value for the matrix sigma, the residual variance-covariance matrix
            sigma=sig*sigmatilde;

            % initiate value for eyesigma
            % compute the inverse of sigma
            C=bear.trns(chol(bear.nspd(sigma),'Lower'));
            invC=C\speye(numCountries*numEndog);
            invsigma=invC*invC';

            % then compute eyesigma
            eyesigma=kron(speye(T),invsigma);

            % finally, initiate eyetheta
            eyetheta=kron(speye(T),theta);

            function sample = sampler()

                % step 2: obtain sigmatilde
                % compute Sbar
                Sbar=(1/sig)*(Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)';
                sigmatilde=bear.iwdraw(Sbar,T);

                % step 3: obtain sig
                % compute the inverse of sigmatilde
                C=bear.trns(chol(bear.nspd(sigmatilde),'Lower'));
                invC=C\speye(numCountries*numEndog);
                invsigmatilde=invC*invC';
                % compute deltabar
                deltabar=trace((Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)'*invsigmatilde)+delta0;
                % draw sig
                sig=bear.igrandn(alphabar/2,deltabar/2);

                % step 4: compute sigma and eyesigma
                sigma=sig*sigmatilde;
                C=bear.trns(chol(bear.nspd(sigma),'Lower'));
                invC=C\speye(numCountries*numEndog);
                invsigma=invC*invC';
                eyesigma=kron(speye(T),invsigma);

                % step 5: obtain theta
                % compute Thetabar
                invThetabar=full((Xtilde*eyesigma*Xtilde'+invTheta0));
                C=bear.trns(chol(bear.nspd(invThetabar),'Lower'));
                invC=C\speye(d);
                Thetabar=invC*invC';
                % compute thetabar
                thetabar=Thetabar*(Xtilde*eyesigma*y+invTheta0*theta0);
                % draw theta
                theta=thetabar+chol(bear.nspd(Thetabar),'lower')*mvnrnd(zeros(d,1),eye(d))';

                % step 6: obtain eyetheta
                eyetheta=kron(speye(T),theta);

                sigma_gibbs = bear.vec(sigma);
                % recalculate beta_gibbs
                beta_gibbs = Xi*theta;

                sample = struct();
                sample.beta = beta_gibbs;
                sample.sigma = sigma_gibbs;

            end

            % burn first Bu sample before returning sampler
            for count=1:Bu
                sampler();
            end

            this.Sampler = @sampler;

            %]
        end%

        
        function createDrawers(this, meta)
            numTotalEndog = meta.NumUnits*meta.NumEndogenousConcepts;
            numARows = numTotalEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numBRows = numARows+numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            function draw = betaDrawer(sample, horizon)

                beta = sample.beta;

                B = reshape(beta, numBRows, numTotalEndog);
                A = B(1:numARows, :);
                C = B(numARows+1:end, :);

                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
            end

            function draw = sigmaDrawer(sample, horizon)

                sigma = sample.sigma;

                Sigma = reshape( ...
                    sigma, ...
                    numTotalEndog, ...
                    numTotalEndog ...
                );

                draw = struct();
                draw.Sigma = Sigma;
            end

            function draw = drawer(sample, horizon)

                draw = betaDrawer(sample, horizon);
                drawS = sigmaDrawer(sample, horizon);
                draw.Sigma = drawS.Sigma;

            end

            function draw = unconditionalDrawer(sample, start, forecastHorizon)

                draw = betaDrawer(sample, forecastHorizon);
                drawS = sigmaDrawer(sample, forecastHorizon);
                draw.Sigma = repmat({drawS.Sigma}, forecastHorizon, 1);

            end%

            function draw = historyDrawer(sample)

                draw = betaDrawer(sample, estimationHorizon);
                drawS = sigmaDrawer(sample, estimationHorizon);
                draw.Sigma = repmat({drawS.Sigma}, estimationHorizon, 1);

            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon)

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

