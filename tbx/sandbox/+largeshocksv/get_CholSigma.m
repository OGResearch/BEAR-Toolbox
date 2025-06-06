function [cholSigma, H, F] = get_CholSigma(pars)

    F     = pars.F;
    H     = largeshocksv.get_H(pars);
    Fi    = largeshocksv.unvech(F, 0, 1);
    numEn = size(H, 1);
    estimLength = size(H, 2);
    cholSigma = nan(numEn, numEn, estimLength);
    for t = 1 : estimLength
        cholSigma(:, :, t) = Fi \ diag(sqrt(H(:, t)));
    end
end