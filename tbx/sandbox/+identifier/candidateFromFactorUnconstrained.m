
function D = candidateFromFactorUnconstrained(P)

    X = randn(size(P));
    [Q, R] = qr(X);
    Q = Q * diag(diag(sign(R)));
    D = Q * P;

end%

