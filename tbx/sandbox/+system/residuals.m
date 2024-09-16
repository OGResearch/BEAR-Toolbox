
function U = residuals(A, C, dataYLX)

    [Y, L, X] = dataYLX{:};
    U = Y - L * A - X * C;

end%

