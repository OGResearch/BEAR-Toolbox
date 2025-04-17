    function pars = drawLogLambdaSV(pars, prior, numEn, estimLength, Y, LX)

      invA  = largeshocksv.unvech(pars.F, 0, 1);
      logLambda = pars.logLambda;

      cholPhi = largeshocksv.unvech(pars.cholPhi);

      resid = Y - LX * pars.B;

      rotResid  = invA * resid';

      [gridKSC, gridKSCt, logy2offset] = largeshocksv.getKSC7values(estimLength, numEn);

      logy2resid = log(rotResid.^2 + logy2offset);

      [curr] = ...
        largeshocksv.StochVolKSCcorrsqrt(logy2resid, logLambda, cholPhi, ...
        prior.meanLogLambda0', prior.covLogLambda0, ...
        gridKSC, gridKSCt, numEn, estimLength);

      pars.logLambda = curr;

    end