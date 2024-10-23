classdef NormalWishartPanel < estimator.Base

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

            ar = this.Settings.Autoregression;
            lambda1 = this.Settings.Lambda1;
            lambda3 = this.Settings.Lambda3;
            lambda4 = this.Settings.Lambda4;
            priorexo = this.Settings.Exogenous;;

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

                a_temp = beta_temp(1:numEndog*numLags,:);

                c_temp = beta_temp(numEndog*numLags+1:end,:);

                % iterate over countries
                for ii = 1:numCountries

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

