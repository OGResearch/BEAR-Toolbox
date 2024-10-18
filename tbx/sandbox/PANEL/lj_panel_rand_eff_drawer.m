function [drawerH, timelessDrawerH] = lj_panel_rand_eff_drawer(meta)
    % input 
    % smpl - one sample (gibbs sampling) that contains:
    % smpl.beta - one sample of beta gibbs
    % smpl.sigma - one sample of sigma gibbs

    % output
    % A - transformed matrix of parameters in front of transition variables
    % C - tranformed matrix of parameters in front of exogenous and constant
    % Sigma - transformed matrix of variance covariance of shocks
    % Y = (L)Y*A + X*C + eps

    numCountries = meta.numCountries;
    numEndog     = meta.numEndog;
    numLags      = meta.numLags;
    numExog      = meta.numExog;

    function drawer = drawer(sampleStruct, horizon)

        smpl = sampleStruct;
        beta = smpl.beta;
        sigma = smpl.sigma;
        
        % initialization
        A = [];
        C = [];

        Sigma = [];

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

          A = blkdiag(A, a_temp);

          C = [C, c_temp];

          Sigma = blkdiag(Sigma,sigma_temp);

        end

        % initialize the output
        drawer = struct();
        drawer.As = cell(horizon,1);
        drawer.Cs = cell(horizon,1);
        drawer.Sigmas = cell(horizon,1);

        % pack the output
        for tt = 1:horizon

          drawer.As{tt} = A;
          drawer.Cs{tt} = C;
          drawer.Sigmas{tt} = Sigma;

        end

    end

    
    function timelessDrawer = timelessDrawer(sampleStruct, start, horizon)

      timelessDrawer = drawer(sampleStruct, horizon);

    end

    % return function calls
    drawerH = @drawer;
    timelessDrawerH = @timelessDrawer;

end