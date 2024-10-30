
%{
%
% system.contributionsExogenous  Calculate contributions of exogenous variables
% to endogenous variables
%
%}

function C = contributionsExogenous(A, IC, IX)

    arguments
        A (:, 1) cell {mustBeNonempty}
        IC (:, :) double
        IX (:, :) double
    end

    [order, numY] = system.orderFromA(A{1});
    numIX = size(IX, 2);
    numT = size(IX, 1);

    % Work with C as numY x numE x numT
    C = zeros(numY, 1, numT);
    lt = zeros(numY * order, numE);

    ct = IX(1, :) * C;
    C(:, :, 1) = ct;

    for t = 2 : numT
        lt = [ct; lt(1:end-numY, :)];
        ixt = IX(t, :);
        ct = lt * A{t} + ixt * IC;
        C(:, :, t) = ct;
    end

    % Permute the final C into numT x numY x numE
    C = permute(C, [3, 1, 2]);

end%

