
function [Y, init] = forecast(A, C, YX, U)

    [Y, X] = YX{:};

    numT = size(X, 1);
    numY = size(A, 2);
    order = size(A, 1) / numY;
    if round(order) ~= order
        error("Invalid system matrix A")
    end

    numYY = numY * order;

    yy = X(1, 1:numYY);

    if nargout > 1
        init = transpose(reshape(yy, numY, order));
        init = init(end:-1:1, :);
    end

    XX = X(:, numYY+1:end);
    XX_C = XX * C;

    for t = 1 : numT
        y = yy * A + XX_C(t, :) + U(t, :);
        yy = [y, yy(1:end-numY)];
        Y(t, :) = y;
    end

end%

