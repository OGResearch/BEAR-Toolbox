function [Y, LX] = getRegimeData(th, delay, thresholdvar,...
    Y, LX, dummy, r)

  regimeInd = threshold.getRegimeInd(th, delay, thresholdvar, r);

  Y = [Y(regimeInd, :); dummy.Y];
  LX = [LX(regimeInd, :); dummy.X];

end