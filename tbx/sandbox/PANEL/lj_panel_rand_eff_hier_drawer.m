function [outUnconditionalDrawer, outIdentifierDrawer] = lj_panel_rand_eff_hier_drawer(this, meta)

    numCountries = meta.numCountries;
    numEndog     = meta.numEndog;
    numLags      = meta.numLags;
    numExog      = meta.numExog;
    
    %IRF periods
    IRFperiods = meta.IRFperiods;

    EstimationSpan = this.EstimationSpan;
    
    function [As, Cs, Sigma] = identificationDrawer(sampleStruct)

        % input 
        % smpl - one sample (gibbs sampling) that contains:
        % smpl.beta - one sample of beta gibbs
        % smpl.sigma - one sample of sigma gibbs

        % output
        % A - transformed matrix of parameters in front of transition variables
        % C - tranformed matrix of parameters in front of exogenous and constant
        % Sigma - transformed matrix of variance covariance of shocks
        % Y = (L)Y*A + X*C + eps

        smpl = sampleStruct;
        beta = smpl.beta;
        sigma = smpl.sigma;
        
        % initialization
        A = [];
        C = [];

        Sigma = [];

        % initialize the output
        drawStruct.As =cell(IRFperiods,1);
        Cs = cell(IRFperiods,1);

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

            A = blkdiag(A, a_temp);

            C = [C, c_temp];
            
            Sigma = blkdiag(Sigma,sigma_temp);

        end

        % pack the output
        for tt = 1:IRFperiods

            drawStruct.As{tt} = A;
            Cs{tt} = C;

        end
    end

    function drawStruct = unconditionalDrawer(sampleStruct, forecastStart,forecastHorizon)

        % call the identificationDrawer as for the time invariant models, results are almost the same
        [As, Cs, Sigma] = identificationDrawer(sampleStruct, forecastHorizon);

        Sigmas  = cell(forecastHorizon,1);

        % pack the output
        for tt = 1:forecastHorizon

            Sigmas{tt} = Sigma;

        end

    end

    % return function calls
    outIdentifierDrawer = @identificationDrawer;

    outUnconditionalDrawer = @unconditionalDrawer;
    
end