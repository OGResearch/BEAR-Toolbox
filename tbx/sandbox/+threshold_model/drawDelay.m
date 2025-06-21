function delay = drawDelay(maxDelay, B, sigma, threshold, thresholdvar,...
    meanThreshold, varThreshold, Y, LX)
    
      logProb = nan(maxDelay, 1);
      for d = 1 : maxDelay
        logProb(d) = threshold_model.logPostPDF(B, sigma, threshold, d, ...
            thresholdvar, meanThreshold, varThreshold, Y, LX);
      end

      expLogProbNorm = exp(logProb - mean(logProb));
      prob = expLogProbNorm / sum(expLogProbNorm);

      delay = largeshocksv.randdiscr(prob, 1);

      randperm(1);

end
