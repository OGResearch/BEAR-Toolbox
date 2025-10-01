
%{
%
% system.forecast  Calculate forecast for reduced-form VARX model
%
%}

function [shortY, initY, shortX] = forecast(A, C, longYXZ, U, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        longYXZ (1, 3) cell
        U (:, :, :) double
        options.HasIntercept % (1, 1) logical
        options.Order % (1, 1) double {mustBeInteger, mustBePositive}
    end

    hasIntercept = options.HasIntercept;
    order = options.Order;

    horizon = numel(A);
    [longY, longX, ~] = longYXZ{:};
    numY = size(A{1}, 2);
    numUnits = size(A{1}, 3);

    shortX = longX(order+1:end, :);
    shortXI = system.addInterceptWhenNeeded(shortX, hasIntercept);

    initY = longY(1:order, :, :);

    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(shortXI, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    shortY = cell(1, numUnits);
    for n = 1 : numUnits
        shortY{n} = nan(horizon, numY);
        lt = system.reshapeInit(initY(:, :, n));
        for t = 1 : horizon
            yt = lt * A{t}(:, :, n) + shortXI(t, :) * C{t}(:, :, n) + U(t, :, n);
            lt = [yt, lt(:, 1:end-numY)];
            shortY{n}(t, :) = yt;
        end
    end
    shortY = cat(3, shortY{:});

end%

