
function U = sampleResiduals(Sigma, numPeriods, options)

    arguments
        Sigma (:, :) double
        numPeriods (1, 1) double
        options.StochasticResiduals (1, 1) logical = true
    end

    numU = size(Sigma, 1);
    if options.StochasticResiduals
        Sigma = (Sigma + Sigma') / 2;
        P = chol(Sigma);
        Z = randn(numU, numPeriods)';
        U = Z * P;
    else
        U = zeros(numPeriods, numU);
    end

end%

