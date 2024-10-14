
classdef NormalWishart_FAVAR < estimator.Base

    methods
        function initializeSampler(this, YXZ, favar)
            arguments
                this
                YXZ (1, 3) cell
                favar struct
            end
            this.Sampler = this.adapterForSampler(YXZ, favar); %Q: where should we initialize YXZ and the favar?
        end%


        function outSampler = adapterForSampler(this, YXZ, favar)
            %[
            arguments
                this
                YXZ (1, 3) cell
                favar struct 
            end

            [Y_long, X_long, Z_long] = YXZ{:};

            opt.const = this.Settings.HasConstant;
            opt.p = this.Settings.Order;

            [FY_long, favar] = favars.get_favar_endo(opt, Y_long, favar, Z_long, informationnames);
            [~, ~, ~, LX, ~, ~, ~, ~, ~, n, m, ~, T, k, q] = bear.olsvar(FY_long, X_long, opt.const, opt.p);

            options.Burnin = 0;
            numPresample = 1;

            opt.It = options.Burnin + numPresample;
            opt.Bu = options.Burnin;

            opt.user_ar = this.Settings.Autoregression;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = this.Settings.HasConstant;
            opt.p = this.Settings.Order;

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            %variance from univariate OLS for priors
            arvar = bear.arloop(FY_long, opt.const, opt.p, n);

            %setting up prior
            [prep] = nw_favar.favar_nwprep(n, m, opt.p, k, T, q, FY_long, ar, arvar,...
                                opt.lambda1, opt.lambda3, opt.lambda4, opt.prior, priorexo, favar, LX);
   
            favarX           = favar.X(:,favar.plotX_index); 
            favarplotX_index = favar.plotX_index; 
            onestep          = favar.onestep; 
            XZ0mean          = zeros(n*opt.p,1);            
            XZ0var           = favar.L0*eye(n*opt.p);
            XY               = favar.XY; 
            L                = favar.L;
            Sigma            = bear.nspd(favar.Sigma);
            favar_X          = favar.favar_X;
            nfactorvar       = favar.nfactorvar;
            numpc            = favar.numpc;
            L0               = favar.L0;
            a0               = favar.a0; 
            b0               = favar.b0;
 
            indexnM          = prep.indexnM;
            FY               = prep.FY;

            B_ss             = prep.B_ss;
            sigma_ss         = prep.sigma_ss;

            Bbar             = prep.Bbar;
            phibar           = prep.phibar;
            Sbar             = prep.Sbar;
            alphabar         = prep.alphabar;  
            alphatilde       = prep.alphatilde;
        
            %===============================================================================

            this.SamplerCounter = uint64(0);

            function smpl = sampler()

                if onestep == 1
                    
                    % Sample latent factors using Carter and Kohn (1994)
                    FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, L, Sigma, B_ss, sigma_ss, indexnM);
                    
                    % demean generated factors
                    FY = bear.favar_demean(FY);
                    
                    % Sample autoregressive coefficients B
                    temp = bear.lagx(FY, opt.p);
                    Y = temp(:, 1:n);

                    % set prior values, new with every iteration for onestep only
                    [B0, ~, phi0, S0, alpha0] = bear.nwprior(ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4,...
                        n, m, opt.p, k, q, opt.prior, priorexo);
                    
                    % obtain posterior distribution parameters, new with every iteration for onestep only
                    [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, n, T, k);
                
                end
                
                % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
                stationary = 0;
                
                while stationary == 0
                
                    B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, k, n);
                    [stationary] = bear.checkstable(B(:), n, opt.p, size(B, 1)); %switches stationary to 0, if the draw is not stationary
                
                end
                
                if onestep == 1
                    B_ss(1:n, :) = B';
                end
                
                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma = bear.iwdraw(Sbar, alphabar);
                
                if onestep == 1
                    sigma_ss(1:n, 1:n) = sigma;
                    % Sample Sigma and L
                    [Sigma, L] = bear.favar_SigmaL(Sigma, L, nfactorvar, numpc, onestep, n, favar_X, FY, a0, b0, T, opt.p, L0);
                end

                R2 = bear.favar_R2(favarX, FY, L, favarplotX_index);

                smpl.B = B;
                smpl.sigma = sigma;
                smpl.LX = LX;
                smpl.FY = FY;
                smpl.L = L;
                smpl.R2 = R2;
                this.SamplerCounter = this.SamplerCounter + 1;
            
            end%

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

