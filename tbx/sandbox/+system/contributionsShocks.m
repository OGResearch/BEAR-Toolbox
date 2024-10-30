
%{
%
% system.contributionsShocks  Calculate contributions of shocks to endogenous variables
%
%}

function C = contributionsShocks(A, D, E)

    arguments
        A (:, 1) cell {mustBeNonempty}
        D (:, :) double
        E (:, :) double
    end

    numY = size(A{1}, 2);
    numE = size(E, 2);
    numT = size(E, 1);

    % TODO: Test performance against permutedPulses = cell(numT, 1);
    % permutedPulses is numY x numE x numT to avoid unnecessary permute/ipermute
    permutedPulses = zeros(numY, numE, numT);

    for t = 1 : numT
        et = diag(E(t, :));
        permutedPulses(:, :, t) = et * D;
    end

    C = system.filterPulses(A, permutedPulses);

end%

