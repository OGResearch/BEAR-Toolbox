
function [flag, eigvals] = stability(A, threshold)

    arguments
        A (:, :) double
        threshold (1, 1) double = (1 - 1e-10)
    end

    AA = system.companionA(A);
    eigvals = eig(AA);
    maxAbsEigvals = max(abs(eigvals));
    flag = maxAbsEigvals <= threshold;

end%

