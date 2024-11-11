
%{
%
% system.contributionsExogenous  Calculate contributions of exogenous variables
% to endogenous variables
%
%}

function contribs = contributionsInit(A, longYXZ)

    arguments
        A (:, 1) cell {mustBeNonempty}
        longYXZ (1, 3) cell
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numUnits = size(A{1}, 3);

    initY = longYXZ{1}(1:order, :, :);

    permutedPulses = zeros(1, numY, 1, numUnits);
    lt = zeros(1, numY * order, 1, numUnits);
    for n = 1 : numUnits
        lt(:, :, 1, n) = system.reshapeInit(initY(:, :, n));
    end

    contribs = system.filterPulses(A, permutedPulses, lt);

end%

