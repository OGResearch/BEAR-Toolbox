
function value = verifyIRF(state, endogenousNames, shockNames, period)

    arguments
        state
        endogenousNames (1, :) string
        shockNames (1, :) string
        period (1, :) double
    end

    endogenousIndex = [];
    for n = reshape(string(endogenousNames), 1, [])
        endogenousIndex = [endogenousIndex, state.EndogenousNames.(n)];
    end

    shockIndex = [];
    for n = reshape(string(shockNames), 1, [])
        shockIndex = [shockIndex, state.ShockNames.(n)];
    end

    try
        state.IRF;
    catch
        state.addprop("IRF");
        state.IRF = [];
    end

    maxPeriod = max(period);
    if size(state.IRF, 1) < maxPeriod
        [A, C, Sigma, D, stdVec] = state.System{:};
        state.IRF = system.finiteVMA(A, D, maxPeriod, state.IRF);
    end

    value = state.IRF(period, endogenousIndex, shockIndex);

end%

