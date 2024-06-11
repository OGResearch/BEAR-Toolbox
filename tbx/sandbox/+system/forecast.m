
function [Y, init] = forecast(A, C, YLX, U)

    [Y, L, X] = YLX{:};

    numT = size(X, 1);
    numY = size(A, 2);
    order = size(A, 1) / numY;
    if round(order) ~= order
        error("Invalid system matrix A")
    end

    l = L(1, :);

    if nargout > 1
        init = transpose(reshape(l, numY, order));
        init = init(end:-1:1, :);
    end

    X_C = X * C;

    for t = 1 : numT
        y = l * A + X_C(t, :) + U(t, :);
        l = [y, l(1:end-numY)];
        Y(t, :) = y;
    end

end%

