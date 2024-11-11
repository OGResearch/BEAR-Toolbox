
%{
%
% system.contributionsShocks  Calculate contributions of shocks to endogenous variables
%
%}

function contribs = contributionsShocks(A, D, E)

    arguments
        A (:, 1) cell {mustBeNonempty}
        D (:, :) double
        E (:, :) double
    end

    numT = numel(A);
    numY = size(A{1}, 2);
    numE = size(D, 1);

    % TODO: Test performance against permutedPulses = cell(numT, 1);
    % permutedPulses is numE x numY x numT to avoid unnecessary permute/ipermute
    permutedPulses = zeros(numE, numY, numT);
    for t = 1 : numT
        et = diag(E(t, :));
        permutedPulses(:, :, t) = et * D;
    end

    contribs = system.filterPulses(A, permutedPulses);

end%

