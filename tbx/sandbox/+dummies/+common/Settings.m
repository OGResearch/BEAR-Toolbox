
% dummies.common.Settings  Common settings base for dummies class settings

classdef (CaseInsensitiveProperties=true) Settings < settings.Base

    properties
        Tightness = NaN
    end

    properties (Abstract)
        LegacyOptionMapping (:, 2) string
    end

    methods
        function opt = populateLegacyOptions(this, opt)
            arguments
                this
                opt (1, 1) struct = struct()
            end

            for i = 1 : size(this.LegacyOptionMapping, 1)
                propertyName = this.LegacyOptionMapping(i, 1);
                legacyName = this.LegacyOptionMapping(i, 2);
                if isfield(opt, legacyName)
                    error("Legacy option name %s already exists in the options object", legacyName);
                end
                opt.(legacyName) = this.(propertyName);
            end
        end%
    end

end

