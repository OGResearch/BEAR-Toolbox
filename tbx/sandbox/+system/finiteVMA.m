
function Y = finiteVMA(A, D)

    arguments
        A (:, 1) cell {mustBeNonempty}
        D (:, :) double
    end

    % The output array Y is numT x numY x numP x numUnits
    Y = system.filterPulses(A, D);

end%

