function [A, C, Sigma] = lj_panel_rand_eff_hier_drawer(smpl,numCountries,numEndog,numLags,numExog)
    % input 
    % smpl - one sample (gibbs sampling) that contains:
    % smpl.beta - one sample of beta gibbs
    % smpl.sigma - one sample of sigma gibbs

    % output
    % A - transformed matrix of parameters in front of transition variables
    % C - tranformed matrix of parameters in front of exogenous and constant
    % Sigma - transformed matrix of variance covariance of shocks
    % Y = (L)Y*A + X*C + eps
    
    beta = smpl.beta;
    sigma = smpl.sigma;
    
    % initialization
    A = [];
    C = [];

    Sigma = [];

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
    
end