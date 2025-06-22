function threshold = drawThreshold(B, sigma, threshold, delay, thresholdvar,...
    meanThreshold, varThreshold, Y, LX, propStd)
        
    currLPDF  = threshold.logPostPDF(B, sigma, threshold, delay,...
        thresholdvar,meanThreshold, varThreshold, Y, LX);
    

    cand      = threshold + propStd * randn();
    candLPDF  = threshold.logPostPDF(B, sigma, cand, delay,...
        thresholdvar, meanThreshold, varThreshold, Y, LX);

    alpha     = min(1, exp(candLPDF - currLPDF));
    
    u = rand();
    accepted  =  u < alpha;
    
    if accepted
        threshold = cand;
    end
   

end
