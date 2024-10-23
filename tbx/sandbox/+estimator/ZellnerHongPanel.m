classdef ZellnerHongPanel < estimator.Base

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

            lambda1 = this.Settings.Lambda1;
            
            % compute preliminary elements
            [~, Xibar, Xbar, ~, yi, y, N, n, ~, ~, ~, ~, q, h]=bear.panel3prelim(longY,longX,const,numLags);

            % obtain prior elements
            [~, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);

            % compute posterior distribution parameters
            [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);

            function sampleStruct = sampler()
                
                % draw a random vector beta from N(betabar,omegabarb)
                % TODO - optimize chol (can be run only once)
                beta=betabar+chol(bear.nspd(omegabarb),'lower')*mvnrnd(zeros(h,1),eye(h))';

                beta=reshape(beta,q,N);
                % record values by marginalising over each unit
                for jj=1:N

                    beta_gibbs(:,jj)=beta(:,jj);

                end

                % obtain a record of draws for sigma, the residual variance-covariance matrix
                % compute sigma
                sigma=sigeps*eye(n);

                sigma_gibbs=repmat(sigma(:),[1 N]);

                sampleStruct = struct();
                sampleStruct.beta = beta_gibbs;
                sampleStruct.sigma = sigma_gibbs;

            end
                
            this.Sampler = @sampler;
            %]
        end%


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
                A = nan(numEndog*numLags,numEndog,numCountries);
                C = nan(numExog,numEndog,numCountries);

                Sigma = nan(numEndog,numEndog,numCountries);

                % initialize the output
                As = cell(forecastHorizon,1);
                Cs = cell(forecastHorizon,1);
                Sigmas  = cell(forecastHorizon,1);

                % iterate over countries
                for ii = 1:numCountries

                    beta_temp = reshape(...
                            beta(:,ii),...
                            numEndog*numLags+numExog,...
                            numEndog...
                            );

                    sigma_temp = reshape(...
                            sigma(:,ii),...
                            numEndog,...
                            numEndog...
                            );
                            
                    % Pack in blocks
                    a_temp = beta_temp(1:numEndog*numLags,:);

                    c_temp = beta_temp(numEndog*numLags+1:end,:);

                    % Pack in blocks
                    A(:,:,ii) = a_temp;

                    C(:,:,ii) = c_temp;

                    Sigma(:,:,ii) = sigma_temp;

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
        end%

    end
end

