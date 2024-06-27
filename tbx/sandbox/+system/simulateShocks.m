
function Y = simulateShocks(A, D, numPeriods)

    numShocks = size(D, 1);
    numY = size(A, 2);
    order = size(A, 1) / numY;
    if round(order) ~= order
        error("Invalid system matrix A")
    end

    At = A';
    Dt = D';
    lt = zeros(numY * order, numShocks);
    Yt = zeros(numY, numPeriods, numShocks);

    t = 1;
    yt = Dt;
    Yt(:, t, :) = reshape(yt, numY, 1, numShocks);

    for t = 2 : numPeriods
        lt = [yt; lt(1:end-numY, :)];
        yt = At * lt;
        Yt(:, t, :) = reshape(yt, numY, 1, numShocks);
    end

    % Y is numPeriods by numY by numShocks
    Y = permute(Yt, [2, 1, 3]);

end%

