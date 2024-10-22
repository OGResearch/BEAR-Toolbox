
function U = residuals(A, C, longYXZ, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        longYXZ (1, 3) cell
        %
        options.HasIntercept (1, 1) logical
        options.Order (1, 1) double {mustBeInteger, mustBePositive}
    end

    hasIntercept = options.HasIntercept;
    order = options.Order;

    [longY, longX, ~] = longYXZ{:};

    T = order+1 : size(longY, 1);
    numT = numel(T);

    Y = longY(T, :);

    L = [];
    for i = 1 : order
        L = [L, longY(T-i, :)];
    end

    X = longX(T, :);
    if hasIntercept
        X = [X, ones(numT, 1)];
    end

    U = nan(size(Y));
    for t = 1 : numT
        U(t, :) = Y(t, :) - L(t, :) * A{t} - X(t, :) * C{t};
    end

end%

