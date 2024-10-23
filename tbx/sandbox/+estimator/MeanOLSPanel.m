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
                meta (1, 1) meta.ReducedForm
                longYXZ (1, 3) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX, ~] = longYXZ{:};

            const = meta.HasIntercept;
            numLags = meta.Order;
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;

            % reshape input endogenous matrix
            longY = reshape(longY,size(longY,1),numEndog,numCountries);

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
            numLags = meta.Order;
            numExog = meta.NumExogenousNames+meta.HasIntercept;

            function drawStruct = unconditionalDrawer(sampleStruct, startingIndex, forecastHorizon)

                smpl = sampleStruct;
                beta = smpl.bhat; % forecast is using mean OLS fixed parameters, no draws
                sigma = eye(numEndog,numEndog);
                % sigma = smpl.sigma;

                % initialization
                A = [];
                C = [];

                Sigma = [];

                % initialize the output
                As = cell(forecastHorizon, 1);
                Cs = cell(forecastHorizon, 1);
                Sigmas  = cell(forecastHorizon, 1);

                beta_temp = reshape(...
                            beta,...
                            numEndog*numLags+numExog,...
                            numEndog...
                            );

                sigma_temp = reshape(...
                            sigma,...
                            numEndog,...
                            numEndog...
                            );

                a_temp = beta_temp(1:numEndog*numLags, :);

                c_temp = beta_temp(numEndog*numLags+1:end, :);

                % iterate over countries
                for ii = 1:numCountries

                    % Pack in blocks
                    A = blkdiag(A, a_temp);

                    C = [C, c_temp];

                    Sigma = blkdiag(Sigma,sigma_temp);

                end

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
        end

    end

end
