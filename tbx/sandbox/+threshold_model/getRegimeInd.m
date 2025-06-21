function regimeInd = getRegimeInd(threshold, delay, thresholdvar, r)
      regimeInd = (thresholdvar(:, delay) <= threshold);
      if r == 2
        regimeInd = ~regimeInd;
      end
end