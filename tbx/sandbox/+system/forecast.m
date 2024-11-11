%{
%
% system.forecast  Calculate forecast for reduced-form VARX model
%
%}

function [Y, initY] = forecast(A, C, longYXZ, U, options)

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

    X = longX(order+1:end, :);
    X = system.addInterceptWhenNeeded(X, hasIntercept);

    initY = longY(1:order, :, :);

    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(X, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    Y = cell(1, numUnits);
    for n = 1 : numUnits
        Y{n} = nan(horizon, numY);
        lt = system.reshapeInit(initY(:, :, n));
        for t = 1 : horizon
            yt = lt * A{t}(:, :, n) + X(t, :) * C{t}(:, :, n) + U(t, :, n);
            lt = [yt, lt(:, 1:end-numY)];
            Y{n}(t, :) = yt;
        end
    end
    Y = cat(3, Y{:});

end%

