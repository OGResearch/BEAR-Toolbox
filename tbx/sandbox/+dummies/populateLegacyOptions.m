
function opt = populateLegacyOptions(dummies, opt)

    arguments
        dummies (1, :) cell
        opt (1, 1) struct = struct()
    end

    for i = 1 : numel(dummies)
        d = dummies{i};
        opt = d.Settings.populateLegacyOptions(opt);
    end

end%

