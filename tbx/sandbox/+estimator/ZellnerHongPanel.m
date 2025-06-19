
classdef ZellnerHongPanel < estimator.Base & estimator.PlainPanelDrawersMixin

    methods (Static)
        function info = getModelReference()
            info.category = "panel";
        end
    end
    
    properties
        DescriptionUX = "Zellner-Hong Panel BVAR"

        CanHaveDummies = false
        
        HasCrossUnits = false

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

            lambda1 = this.Settings.Lambda1;

            % compute preliminary elements
            [~, Xibar, Xbar, ~, yi, y, N, n, ~, ~, ~, ~, q, h]=bear.panel3prelim(longY,longX,const,numLags);

            % obtain prior elements
            [~, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);

            % compute posterior distribution parameters
            [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);

            function sample = sampler()

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

                sample = struct();
                sample.beta = beta_gibbs;
                sample.sigma = sigma_gibbs;

            end

            this.Sampler = @sampler;
            %]
        end%
    end

end

