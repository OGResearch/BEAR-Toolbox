%{
%
% system.filterPulses  Filter a sequence of period pulses through a VAR process
%
% ## Syntax
%
%     Y = system.filterPulses(A, permutedPulses)
%
% ## Input arguments
%
% * `A` - Stacked autoregressive matrix
%
% * `permutedPulses` - A numY x numP x numT array
%
% ## Output arguments
%
% * `Y` - A numT x numY x numP array of responses in endogenous variables to the
% permuted pulses
%
%}

function Y = filterPulses(A, permutedPulses, lt)

    arguments
        A (:, 1) cell {mustBeNonempty}
        permutedPulses (:, :, :, :) double
        lt (1, :, :, :) double = double.empty(1, 0)
    end

    numT = numel(A);
    [order, numY] = system.orderFromA(A{1});
    numUnits = size(A{1}, 3);

    % permutedPulses is expected numP x numY x numT to avoid unnecessary
    % permute/ipermute
    numP = size(permutedPulses, 1);
    lastP = size(permutedPulses, 3);

    if numY ~= size(permutedPulses, 2)
        error("The second dimension of permutedPulses must match the number of endogenous variables");
    end

    % Work with Y as numP x numY x numT x numUnits
    Y = zeros(numP, numY, numT, numUnits);

    for n = 1 : numUnits
        if isempty(lt)
            lt = zeros(numP, numY * order);
        end

        t = 1;
        yt = lt * A{t}(:, :, n) + permutedPulses(:, :, t, n);
        Y(:, :, t, n) = yt;

        for t = 2 : lastP
            lt = [yt, lt(:, 1:end-numY)];
            yt = lt * A{t}(:, :, n) + permutedPulses(:, :, t, n);
            Y(:, :, t, n) = yt;
        end

        for t = lastP+1 : numT
            lt = [yt, lt(:, 1:end-numY)];
            yt = lt * A{t}(:, :, n);
            Y(:, :, t, n) = yt;
        end
    end

    % Permute the final array Y into numT x numY x numP x numUnits
    Y = permute(Y, [3, 2, 1, 4]);

end%

