
function stateExacts = exactInstantZero(stateExacts, endogenousNames, shockNames)

    endogenousIndex = [];
    for n = reshape(string(endogenousNames), 1, [])
        endogenousIndex = [endogenousIndex, stateExacts.EndogenousNames.(n)];
    end

    shockIndex = [];
    for n = reshape(string(shockNames), 1, [])
        shockIndex = [shockIndex, stateExacts.ShockNames.(n)];
    end

    if ~isfield(stateExacts, "InstantZero")
        numEndogenous = numel(fieldnames(stateExacts.EndogenousNames));
        numShocks = numel(fieldnames(stateExacts.ShockNames));
        stateExacts.InstantZero = nan(numEndogenous, numShocks);
    end

    if ~isempty(endogenousIndex) && ~isempty(shockIndex)
        stateExacts.InstantZero(shockIndex, endogenousIndex) = 0;
    end

end%

