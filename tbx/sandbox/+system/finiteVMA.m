
function Y = finiteVMA(A, D)

    arguments
        A (:, 1) cell {mustBeNonempty}
        D (:, :) double
    end

    Y = system.filterPulses(A, D);

end%

