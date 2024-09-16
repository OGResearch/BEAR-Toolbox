
function Y = fevdFromVma(Y, varVec, shockIndex)

    jjj

    numPeriods = size(Y, 1);
    numY = size(Y, 2);
    numShocks = size(varVec, 2);

    varVec = varVec(shockIndex);
    varMat = repmat(reshape(varVec, 1, []), numY, 1);
    varMat = permute(varMat, [3, 1, 2]);
    varMat = repmat(varMat, numPeriods, 1, 1);
    Y = cumsum(Y .^ 2, 1) .* varMat;

end%

