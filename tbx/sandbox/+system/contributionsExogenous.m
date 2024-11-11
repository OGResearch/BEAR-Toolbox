
%{
%
% system.contributionsExogenous  Calculate contributions of exogenous variables
% to endogenous variables
%
%}

function contribs = contributionsExogenous(A, C, longYXZ)

    arguments
        A (:, 1) cell {mustBeNonempty}
        C (:, 1) cell {mustBeNonempty}
        longYXZ (1, 3) cell
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numP = 1;

    shortX = longYXZ{2}(order+1:end, :, :);
    hasIntercept = size(C{1}, 1) == size(shortX, 2) + 1;
    shortX = system.addInterceptWhenNeeded(shortX, hasIntercept);

    permutedPulses = zeros(numP, numY, numT);
    for t = 1 : numT
        permutedPulses(:, :, t) = shortX(t, :) * C{t};
    end

    contribs = system.filterPulses(A, permutedPulses);

end%

