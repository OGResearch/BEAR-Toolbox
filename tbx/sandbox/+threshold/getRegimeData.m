function [Y, LX] = getRegimeData(threshold, delay, thresholdvar,...
    Y, LX, dummy, r)

  regimeInd = threshold.getRegimeInd(threshold, delay, thresholdvar, r);

  Y = [Y(regimeInd, :); dummy.Y];
  LX = [LX(regimeInd, :); dummy.X];

end