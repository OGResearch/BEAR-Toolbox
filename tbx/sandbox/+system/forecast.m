
function [Y, initY] = forecast(A, C, longYXZ, U, hasIntercept, order)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        longYXZ (1, 3) cell
        U (:, :) double
        hasIntercept (1, 1) logical
        order (1, 1) double {mustBeInteger, mustBePositive}
    end

    horizon = numel(A);
    [longY, longX, ~] = longYXZ{:};
    numY = size(A{1}, 2);

    X = longX(order+1:end, :);
    if hasIntercept
        X = [X, ones(size(X, 1), 1)];
    end

    initY = longY(1:order, :);

    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(X, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    l = [];
    for i = 1 : order
        l = [initY(i, :), l];
    end

    Y =-nan(horizon, numY);
    for t = 1 : horizon
        y = l * A{t} + X(t, :) * C{t} + U(t, :);
        l = [y, l(1:end-numY)];
        Y(t, :) = y;
    end

end%

