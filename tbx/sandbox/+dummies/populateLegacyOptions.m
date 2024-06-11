
function opt = populateLegacyOptions(dummies, opt)

    arguments
        dummies (1, :) cell
        opt (1, 1) struct = struct()
    end

    opt.iobs = false;
    opt.scoeff = false;
    opt.lrp = false;

    opt.lambda1 = NaN;
    opt.lambda3 = NaN;
    opt.lambda4 = NaN;
    opt.ar = NaN;
    opt.prior = 0;

    opt.lambda6 = NaN;
    opt.lambda7 = NaN;
    opt.lambda8 = NaN;

    for i = 1 : numel(dummies)
        d = dummies{i};
        opt = d.Settings.populateLegacyOptions(opt);
    end

end%

