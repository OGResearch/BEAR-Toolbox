
function shockNames = autogenerateShockNames(numEndogenous)

    arguments
        numEndogenous (1, 1) {mustBeInteger, mustBePositive}
    end

    shockNames = "shock" + string(1:numEndogenous);

end%

