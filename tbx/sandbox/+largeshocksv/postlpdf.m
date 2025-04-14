function y = postlpdf(x, opt, prior, Y, X, T0, numBRows, sizeB, numTheta)
        
    [B, cholSigma, theta] = largeshocksv.pars2mat(x, numBRows, sizeB, numTheta);
    nVars = size(B, 2);
    Sigma = cholSigma*cholSigma';

    [Y, X, sf] = largeshocksv.scaleData(Y, X, T0, theta);
    
    eps = Y - X*B;
    mu = zeros(1, size(eps, 2)); 

    lpdfTheta = ...
        + sum(log(gppdf(theta(1:end-1), opt.scaleTheta, opt.shapeTheta, 1))) ...
        + log(betapdf(theta(end), opt.alphaAR, opt.betaAR));

    priorpdf  = ...
        + largeshocksv.iwlpdf(cholSigma, prior.scaleSigma, prior.dfSigma) ...
        + largeshocksv.mvnlpdf_kron(B - prior.meanB, cholSigma, prior.cholCovB);


    y = sum(log(mvnpdf(eps, mu, Sigma))) - nVars * sum(log(sf)) ...
          + priorpdf ...
          + lpdfTheta;

end

