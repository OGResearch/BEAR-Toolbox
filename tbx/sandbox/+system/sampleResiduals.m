
function U = sampleResiduals(Sigma, options)

    arguments
        Sigma (:, 1) cell
        options.StochasticResiduals (1, 1) logical = true
    end

    numPeriods = numel(Sigma);
    numU = size(Sigma{1}, 1);

    U = zeros(numPeriods, numU);
    if ~options.StochasticResiduals
        return
    end

    for t = 1 : numPeriods
        Sigma_t = Sigma{t};
        Sigma_t = (Sigma_t + Sigma_t') / 2;
        P = cholcov(Sigma_t);
        U(t, :) = randn(1, numU) * P;
    end

end%

