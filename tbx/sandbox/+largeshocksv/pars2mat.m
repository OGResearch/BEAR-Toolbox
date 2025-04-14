function [B, cholSigma, theta] = pars2mat(x, numBRows, sizeB, numTheta)

    theta = x(end - numTheta + 1 : end);
    B = reshape(x(1 : sizeB), numBRows, []);
    cholSigma = largeshocksv.unvech(x(sizeB + 1: end - numTheta));

end