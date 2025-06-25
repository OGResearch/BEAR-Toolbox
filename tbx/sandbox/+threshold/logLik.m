function y = logLik(B, sigma, th, delay, thresholdvar, Y, LX)
    y = 0;
    for r = 1 : 2
        regimeInd = threshold.getRegimeInd(th, delay, thresholdvar, r);
        Yreg = Y(regimeInd, :);
        LXreg = LX(regimeInd, :);
        Breg = B(:, :, r);
        resid = Yreg - LXreg * Breg;
        y = y + sum(largeshocksv.mvnlpdf(resid, chol(sigma(:, :, r),"lower")));
    end
end


