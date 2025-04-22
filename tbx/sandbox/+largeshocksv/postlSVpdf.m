    function logPostPDF = postlSVpdf(pars, prior, Y, LX)

      % Can not use the method of the superclass, since that is fixed volatility

      B = pars.B;

      [cholSigma, H , F] = largeshocksv.get_CholSigma(pars);
      resid = Y - LX * B;

      T = size(resid, 1);
      logLik = 0;
      for t = 1 : T
          logLik = logLik + largeshocksv.mvnlpdf(resid(t, :), cholSigma(:, :, t));
      end

      logH        = log(H);
      cholPhi     = largeshocksv.unvech(pars.cholPhi);

      dlogH = diff(logH');

      logPriorPDF = ...
          + largeshocksv.mvnlpdf((B(:) - prior.meanB(:))', prior.cholCovB) ...
          + largeshocksv.mvnlpdf((F(:) - prior.meanF(:))', prior.cholCovF) ...
          + sum(largeshocksv.iwlpdf(cholPhi, prior.scalePhi, prior.dofPhi)) ...
          + largeshocksv.mvnlpdf(prior.meanlogLambda, prior.cholCovlogLambda) ...
          + sum(largeshocksv.mvnlpdf(dlogH, cholPhi));

      logPostPDF = logLik + logPriorPDF;
    end