function [B,Sigma] = lj_panel_rand_eff_drawer(smpl,N,n,p,m)
    % input 
    % smpl - one sample (gibbs sampling) that contains:
    % smpl.beta - one sample of beta gibbs
    % smpl.sigma - one sample of sigma gibbs

    % output
    % B - transformed matrix of beta
    % Sigma - transformed matrix of sigma
    
    beta = smpl.beta;
    sigma = smpl.sigma;
    % B = zeros(N*n*(n*p+m),(n*N));
    B = [];
    for ii = 1:N
      beta_temp = reshape(beta(:,ii),(n*p+m),n);
      % remove exogenous
      B = blkdiag(B, beta_temp(1:n*p,:));
    end
    Sigma = sigma;
end