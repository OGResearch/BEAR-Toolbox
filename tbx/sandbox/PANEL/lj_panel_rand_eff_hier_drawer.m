function [B,Sigma] = lj_panel_rand_eff_hier_drawer(smpl,numCountries,numEndog,numLags,numExog)
    % input 
    % smpl - one sample (gibbs sampling) that contains:
    % smpl.beta - one sample of beta gibbs
    % smpl.sigma - one sample of sigma gibbs

    % output
    % B - transformed matrix of beta
    % Sigma - transformed matrix of sigma
    
    beta = smpl.beta;
    sigma = smpl.sigma;
    
    B = [];
    Sigma = [];

    for ii = 1:numCountries

      beta_temp = reshape(beta(:,ii),(numEndog*numLags+numExog),numEndog);

      sigma_temp = reshape(sigma(:,ii),numEndog,numEndog);

      % Pack in blocks
      B = blkdiag(B, beta_temp);
      
      Sigma = blkdiag(Sigma,sigma_temp);
    end
    
end