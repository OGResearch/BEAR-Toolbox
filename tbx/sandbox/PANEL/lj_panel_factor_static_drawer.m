function [outUnconditionalDrawer, outIdentifierDrawer] = lj_panel_factor_static_drawer(this, meta)
    
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
        As = cell(IRFperiods,1);
        Cs = cell(IRFperiods,1);

        k = numCountries*numEndog*numLags+numExog;

        B = reshape(beta,k, numCountries*numEndog);

        B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

        % reshaffle B_draw to map the proper order
        for ee = 1:numCountries
            for kk=1:numLags
                B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
            end
        end

        A = B_reshuffled(1:numEndog*numLags*numCountries,:);
        C = B(numEndog*numLags*numCountries+1:end,:);
        
        Sigma = reshape(sigma,numEndog*numCountries,numEndog*numCountries);

        % pack the output
        for tt = 1:IRFperiods

            As{tt} = A;
            Cs{tt} = C;

        end

    end

    function [As, Cs, Sigmas] = unconditionalDrawer(sampleStruct, forecastStart,forecastHorizon)

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