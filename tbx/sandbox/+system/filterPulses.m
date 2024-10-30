%{
%
% system.filterPulses  Filter a sequence of period pulses through a VAR process
%
%}

function Y = filterPulses(A, permutedPulses)

    arguments
        A (:, 1) cell {mustBeNonempty}
        permutedPulses (:, :, :) double
    end

    [order, numY] = system.orderFromA(A{1});
    numT = numel(A);
    numUnits = size(A, 3);

    % permutedPulses is expected numY x numP x numT to avoid unnecessary
    % permute/ipermute
    numP = size(permutedPulses, 2);
    lastP = size(permutedPulses, 3);

    % Work with Y as numY x numP x numT
    Y = zeros(numY, numP, numT, numUnits);
    lt = zeros(numP, numY * order);

    yt = permutedPulses(:, :, 1);
    Y(:, :, 1) = yt;

    for t = 2 : lastP
        lt = [yt, lt(:, 1:end-numY)];
        yt = lt * A{t} + permutedPulses(:, :, t);
        Y(:, :, t) = yt;
    end

    for t = lastP+1 : numT
        lt = [yt, lt(:, 1:end-numY)];
        yt = lt * A{t};
        Y(:, :, t) = yt;
    end
    % Permute the final Y into numT x numY x numP
    Y = permute(Y, [3, 1, 2]);

end%

