function [Y, X, sf] = scaleData(Y, X, T0, theta)

    T   = size(Y, 1);
    sf  = largeshocksv.scaleFactor(theta, T, T0);
    Y   = Y ./ sf;
    X   = X ./ sf;

end
