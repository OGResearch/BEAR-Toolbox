
function Y = finiteVMA(A, D, numPeriods, Y0)

    arguments
        A (:, :) double
        D (:, :) double
        numPeriods (1, 1) double
        Y0 (:, :) double = []
    end

    numE = size(D, 1);
    numY = size(A, 2);
    order = size(A, 1) / numY;
    if round(order) ~= order
        error("Invalid size of system matrix A")
    end

    At = transpose(A);
    Dt = transpose(D);
    lt = zeros(numY * order, numE);

    Y = zeros(numY, numE, numPeriods);

    t = 1;
    yt = Dt;
    Y(:, :, t) = yt;

    for t = 2 : numPeriods
        lt = [yt; lt(1:end-numY, :)];
        yt = At * lt;
        Y(:, :, t) = yt;
    end

    % Y is numPeriods -by- numY -by- numE
    Y = permute(Y, [3, 1, 2]);

end%

