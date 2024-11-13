
function D = candidateFromFactorConstrained(P, R)

    % Transpose from row-oriented to column-oriented VAR systems
    % Row-oriented means time-t vectors of variables are row vectors
    P = transpose(P);
    R = transpose(R);

    % Calculations for column-oriented VAR system
    n = size(P, 1);
    Q = nan(n, n);

    for i = 1 : n
        inx = R(:, i) == 0;
        Z = [P(inx, :); transpose(Q(:, 1:i-1))];
        B = null(Z);
        v = randn(size(B, 2), 1);
        Q(:, i) = B * v / norm(v);
    end

    if any(isnan(Q(:)))
        error("Cannot find orthonormal matrix with the given instant zero restrictions.");
    end

    % Rotate the Cholesky factor matrix to get the candidate D matrix
    D = P * Q;

    % Transpose back to row-oriented VAR systems
    D = transpose(D);

end%

