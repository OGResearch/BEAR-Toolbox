
function flag = stability(A, threshold)

    arguments
        A (:, :) double
        threshold (1, 1) double = (1 - 1e-10)
    end

    AA = reducedForm.system.companion(A);
    absEigvals = abs(eig(AA));
    flag = all(absEigvals <= threshold);

end%

