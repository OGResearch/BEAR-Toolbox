
classdef NormalDiffuse < estimator.Base

    methods
        function initializeSampler(this, YLX)
            arguments
                this
                YLX (1, 3) cell
            end
            this.Sampler = this.adapterForSampler(YLX);
        end%


        function outSampler = adapterForSampler(this, YLX)
            %[
            arguments
                this
                YLX (1, 3) cell
            end

            [Y, L, X] = YLX{:};
            init = system.extractInitial(YLX);

            options.Burnin = 0;
            numPresample = 1;
            opt.It = options.Burnin + numPresample;
            opt.Bu = options.Burnin;

            opt.priorsexogenous = this.Settings.Exogenous;
            opt.user_ar = this.Settings.Autoregression;
            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;            
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, n, m);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.none = 41;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = this.Settings.HasConstant;

            opt.bex  = this.Settings.BlockExogenous;

            T = size(Y, 1);
            n = size(Y, 2);
            m = size(X, 2);
            pn = size(L, 2);
            p = pn / n;

            k = n * p + m;
            q = n * k;
            % m = k - n * p;
            LX = [L, X];

            opt.p = p;
            priorexo = this.Settings.Exogenous;

            % individual priors 0 for default
        %     if isscalar(priorexo)
        %         priorexo = repmat(priorexo, n, m);
        %     end

            %create a vector for AR hyperparamters
        %     if isscalar(this.Settings.Autoregression)
        %         this.Settings.Autoregression = repmat(this.Settings.Autoregression, n, 1);
        %     end
            ar = this.Settings.Autoregression;

            %variance from univariate OLS for priors
            % arvar = bear.arloop([init; Y], opt.const, opt.p, n);
            arvar = bear.arloop([init; Y], opt.const, opt.p, n);

            %setting up prior
            [beta0, omega0] = bear.ndprior(ar, arvar, opts.lambda1, opts.lambda2, opts.lambda3, opts.lambda4, opts.lambda5, ...
                n, m, p, k, q, opts.bex, blockexo, priorexo);
            invomega0 = diag(1./diag(omega0));
            B = Bhat;

            %===============================================================================

            this.SamplerCounter = uint64(0);

            function redSample = sampler()
                % draw sigma from IW, conditional on beta from previous iteration
                % obtain first Shat, defined in (1.6.10)
                Shat = (Y - X*B)'*(Y - X*B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C'*C;
                
                % next draw from IW(Shat,T)
                sigma = bear.iwdraw(Shat,T);
                
                % Continue iteration by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
                % first invert sigma
                C = chol(bear.nspd(sigma));
                invC = C\speye(n);
                invsigma = invC*invC';
                
                % then obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, X'*X);
                C = chol(bear.nspd(invomegabar));
                invC = C\speye(q);
                omegabar = invC*invC';
                
                % following, obtain betabar
                betabar = omegabar*(invomega0*beta0 + kron(invsigma,X')*y);
                
                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar),'lower')*mvnrnd(zeros(q,1),eye(q))';
                
                % update matrix B with each draw
                B = reshape(beta,size(B));
               
                redSample = {reshape(B, 1, 1, []), reshape(sigma, 1, 1, [])};
                this.SamplerCounter = this.SamplerCounter + 1;
            end

            outSampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

