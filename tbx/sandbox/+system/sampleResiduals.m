
function U = sampleResiduals(Sigma, numPeriods, options)

    arguments
        Sigma (:, :) double
        numPeriods (1, 1) double
        options.StochasticResiduals (1, 1) logical = true
    end

    numU = size(Sigma, 1);
    if options.StochasticResiduals
        P = cholcov(Sigma);
        U = randn(numPeriods, numU) * P;
    else
        U = zeros(numPeriods, numU);
    end

end%

