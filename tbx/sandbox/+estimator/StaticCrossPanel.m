classdef StaticCrossPanel < estimator.Base

    properties
        CanHaveDummies = false
        CanHaveReducibles = false
        HasCrossUnits = true
    end


    methods

        function initializeSampler(this, meta, longYXZ, dummiesYLX)
            %[
            arguments
                this
                meta (1, 1) meta.ReducedForm
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

            function sampleStruct = sampler()

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

                sampleStruct = struct();
                sampleStruct.beta = beta_gibbs;
                sampleStruct.sigma = sigma_gibbs;

            end

            % burn first Bu sample before returning sampler
            for count=1:Bu
                sampler();
            end

            this.Sampler = @sampler;

            %]
        end


        function createDrawers(this, meta)
            %[

            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numLags = meta.Order;
            numExog = meta.NumExogenousNames+meta.HasIntercept;

            function drawStruct = unconditionalDrawer(sampleStruct, startingIndex, forecastHorizon)

                smpl = sampleStruct;
                beta = smpl.beta;
                sigma = smpl.sigma;

                % initialization
                A = [];
                C = [];

                Sigma = [];

                % initialize the output
                As = cell(forecastHorizon,1);
                Cs = cell(forecastHorizon,1);
                Sigmas  = cell(forecastHorizon,1);

                k = numCountries*numEndog*numLags+numExog;

                B = reshape(beta,k, numCountries*numEndog);

                A = B(1:numEndog*numLags*numCountries,:);

                C = B(numEndog*numLags*numCountries+1:end,:);

                Sigma = reshape(...
                            sigma,...
                            numEndog*numCountries,...
                            numEndog*numCountries);

                % pack the output
                for tt = 1:forecastHorizon

                    As{tt} = A;
                    Cs{tt} = C;
                    Sigmas{tt} = Sigma;

                end

                drawStruct = struct();
                drawStruct.A = As;
                drawStruct.C = Cs;
                drawStruct.Sigma = Sigmas;
            end

            % return function calls
            % this.IdentificationDrawer = [];

            this.UnconditionalDrawer = @unconditionalDrawer;

            %]
        end%

    end

end
