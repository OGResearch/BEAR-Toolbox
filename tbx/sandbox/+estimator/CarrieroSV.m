classdef CarrieroSV < estimator.Base

    properties
        CanHaveDummies = false
        CanHaveReducibles = false
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

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;
            opt.priorsexogenous = this.Settings.Exogenous;

            opt.gamma = this.Settings.HeteroskedasticityAutoRegression;
            opt.alpha0 = this.Settings.HeteroskedasticityShape;
            opt.delta0 = this.Settings.HeteroskedasticityScale;

            opt.ar = this.Settings.Autoregression;

            priorexo = this.Settings.Exogenous;


            [~, betahat, sigmahat, LX, ~, Y, ~, ~, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            [arvar]  =  bear.arloop(longY, opt.const, p, numEn);


            %create matrices
            [yt, Xt, Xbart]  =  bear.stvoltmat(Y, LX, numEn, estimLength); %create TV matrices
            [B0, phi0, G, I_o, omega, f0, upsilon0] = bear.stvol3prior(opt.ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, ...
                numEn, numEx, p, estimLength, numBRows, sizeB, opt.gamma, priorexo);

            % preliminary elements for the algorithm
            % compute the product G' * I_gamma * G (to speed up computations of deltabar)
            GIG = G' * I_o * G;

            % compute alphabar
            alphabar = estimLength + opt.alpha0;


            % step 1: determine initial values for the algorithm

            % initial value for beta
            beta = betahat;

            B = reshape(beta, numBRows, numEn);

            % initial value for f_2, ..., f_n
            % obtain the triangular factorisation of sigmahat
            [Fhat,  Lambdahat] = bear.triangf(sigmahat);

            % obtain the initial value for F
            F = Fhat;

            % obtain the inverse of Fhat
            [invFhat] = bear.invltod(Fhat, numEn);

            % create the cell storing the different vectors of invF
            Finv = cell(numEn, 1);

            % store the vectors
            for ii = 2:numEn
                Finv{ii, 1} = invFhat(ii, 1:ii - 1);
            end

            % initial values for L
            L = zeros(estimLength, 1);

            % initial values for phi
            phi = 1;

            % step 2: determine the sbar values and Lambda
            sbar = diag(Lambdahat);
            Lambda = sparse(diag(sbar));

            % then determine sigma^(0)
            sigma = F * Lambda * F';


            % step 3: recover the series of initial values for lambda_1, ..., lambda_T and sigma_1, ..., sigma_T
            lambda_t = repmat(diag(sbar), 1, 1, estimLength);
            sigma_t  =  repmat(sigmahat, 1, 1, estimLength);

            function sampleStruct  =  sampler()

                summ1 = zeros(numBRows, numBRows);
                summ2 = zeros(numBRows, numEn);

                % run the summation
                for zz = 1:estimLength
                    prodt = Xt{zz, 1}' * exp( -L(zz, 1));
                    summ1 = summ1 + prodt * Xt{zz, 1};
                    summ2 = summ2 + prodt * yt(:, :, zz)';
                end

                % then obtain the inverse of phi0
                invphi0 = diag(1. / diag(phi0));

                % obtain the inverse of phibar
                invphibar = summ1 + invphi0;

                % recover phibar
                C = chol(bear.nspd(invphibar), 'Lower')';
                invC = C \ speye(numBRows);
                phibar = invC * invC';

                % recover Bbar
                Bbar = phibar * (summ2 + invphi0 * B0);

                % draw B from its posterior
                B = bear.matrixndraw(Bbar, sigma, phibar, numBRows, numEn);

                % finally recover beta by vectorising
                beta = B(:);

                % step 5: draw the series f_2, ..., f_n from their conditional posteriors
                % recover first the residuals
                for zz = 1:estimLength
                    epst(:, :, zz) = yt(:, :, zz) - Xbart{zz, 1} * beta;
                end

                % then draw the vectors in turn
                for zz = 2:numEn
                    % first compute the summations required for upsilonbar and fbar
                    summ1 = zeros(zz - 1, zz - 1);
                    summ2 = zeros(zz - 1, 1);

                    % run the summation
                    for kk = 1:estimLength
                        prodt = epst(1:zz - 1, 1, kk) * exp( -L(kk, 1));
                        summ1 = summ1 + prodt * epst(1:zz - 1, 1, kk)';
                        summ2 = summ2 + prodt * epst(zz, 1, kk)';
                    end

                    summ1 = (1 / sbar(zz, 1)) * summ1;
                    summ2 = ( - 1 / sbar(zz, 1)) * summ2;

                    % then obtain the inverse of upsilon0
                    invupsilon0 = diag(1. / diag(upsilon0{zz, 1}));

                    % obtain upsilonbar
                    invupsilonbar = summ1 + invupsilon0;
                    C = chol(bear.nspd(invupsilonbar));
                    invC = C \ speye(zz - 1);
                    upsilonbar = full(invC * invC');

                    % recover fbar
                    fbar = upsilonbar * (summ2 + invupsilon0 * f0{zz, 1});

                    % finally draw f_i^( - 1)
                    Finv{zz, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(zz - 1, 1);
                end

                % recover the inverse of F
                invF = eye(numEn);
                for zz = 2:numEn
                    invF(zz, 1:zz - 1) = Finv{zz, 1};
                end

                % eventually recover F
                F = bear.invltod(invF, numEn);

                % update sigma
                sigma = F * Lambda * F';


                % step 6: draw phi from its conditional posterior
                % estimate deltabar
                deltabar = L' * GIG * L + opt.delta0;

                % draw the value phi_i
                phi = bear.igrandn(alphabar / 2, deltabar / 2);


                % step 7: draw the series lambda_t from their conditional posteriors,  t = 1, ..., estimLength
                % consider periods in turn
                for kk = 1:estimLength
                    % a candidate value will be drawn from N(lambdabar, phibar)
                    % the definitions of lambdabar and phibar varies with the period,  thus define them first
                    % if the period is the first period
                    if kk == 1
                        lambdabar = (opt.gamma * L(2, 1)) / (1 / omega + opt.gamma^2);
                        phibar = phi / (1 / omega + opt.gamma^2);

                        % if the period is the final period
                    elseif kk == estimLength
                        lambdabar = opt.gamma * L(estimLength - 1, 1);
                        phibar = phi;

                        % if the period is any period in - between
                    else
                        lambdabar = (opt.gamma / (1 + opt.gamma^2)) * (L(kk - 1, 1) + L(kk + 1, 1));
                        phibar = phi / (1 + opt.gamma^2);
                    end

                    % now draw the candidate
                    cand = lambdabar + phibar^0.5 * randn;

                    % compute the acceptance probability
                    prob = bear.mhprob3(cand, L(kk, 1), sbar, epst(:, 1, kk), Finv, numEn);

                    % draw a uniform random number
                    draw = rand;

                    % keep the candidate if the draw value is lower than the prob
                    if draw <= prob
                        L(kk, 1) = cand;
                        % if not,  just keep the former value
                    end
                end

                % then recover the series of matrices lambda_t and sigma_t
                for kk = 1:estimLength
                    lambda_t(:, :, kk) = exp(L(kk, 1)) * diag(sbar);
                    sigma_t(:, :, kk) = F * lambda_t(:, :, kk) * F';
                end

                sampleStruct.beta = beta;
                sampleStruct.F = F;
                sampleStruct.L = mat2cell(L, ones(estimLength, 1), 1);
                sampleStruct.phi = phi;
                sampleStruct.sigmaAvg = sigma(:);
                sampleStruct.sbar = sbar;


                for zz = 1:estimLength
                    sampleStruct.lambda_t_gibbs{zz, 1} = lambda_t(:, :, zz);
                    sampleStruct.sigma_t_gibbs{zz, 1} = sigma_t(:, :, zz);
                end

            end

            this.Sampler = @sampler;

        end

        function createDrawers(this, meta)

            %sizes
            numEn = meta.NumEndogenousNames;
            numARows = numEn * meta.Order;
            numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;

            %IRF periods
            % IRFperiods = meta.IRFperiods;

            %other settings
            gamma = this.Settings.HeteroskedasticityAutoRegression;


            function drawStruct = unconditionalDrawer(sampleStruct, startingIndex, forecastHorizon )

                beta = sampleStruct.beta;
                % reshape it to obtain B
                B = reshape(beta, numBRows, numEn);

                % draw F from its posterior distribution
                F = sparse(sampleStruct.F(:,:));

                % step 4: draw phi and gamma from their posteriors
                phi = sampleStruct.phi;
                lambda =  sampleStruct.L{startingIndex-1, 1};
                sbar = sampleStruct.sbar;

                drawStruct.Sigma = cell(forecastHorizon, 1);

                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);
                drawStruct.A = repmat({A}, forecastHorizon, 1);
                drawStruct.C = repmat({C}, forecastHorizon, 1);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods estimLength+1 to estimLength+h
                for jj = 1:forecastHorizon

                    lambda = gamma * lambda + phi^0.5 * randn;

                    % obtain Lambda_t
                    Lambda = sparse(diag(exp(lambda * sbar)));

                    % recover sigma_t and draw the residuals
                    drawStruct.Sigma{jj, 1}(:, :) = full(F * Lambda * F');
                end
            end

            function drawStruct = identificationDrawer(sampleStruct, horizon)

                beta = sampleStruct.beta;
                % reshape it to obtain B
                B = reshape(beta, numBRows, numEn);

                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);

                drawStruct.A = repmat({A}, horizon, 1);
                drawStruct.C = repmat({C}, horizon, 1);
                drawStruct.Sigma = repmat({reshape(sampleStruct.sigmaAvg, numEn, numEn)}, horizon, 1);

            end


            this.UnconditionalDrawer = @unconditionalDrawer;
            this.IdentificationDrawer = @identificationDrawer;

        end

    end
end