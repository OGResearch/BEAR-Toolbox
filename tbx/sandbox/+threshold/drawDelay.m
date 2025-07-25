function delay = drawDelay(maxDelay, B, sigma, th, thresholdvar,...
    meanThreshold, varThreshold, Y, LX)
    
      logProb = nan(maxDelay, 1);
      for d = 1 : maxDelay
        logProb(d) = threshold.logPostPDF(B, sigma, th, d, ...
            thresholdvar, meanThreshold, varThreshold, Y, LX);
      end

      expLogProbNorm = exp(logProb - mean(logProb));
      prob = expLogProbNorm / sum(expLogProbNorm);

      delay = largeshocksv.randdiscr(prob, 1);

      randperm(1);

end
