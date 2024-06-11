
% model.Structural.Meta  Meta data for structural VAR objects

classdef Meta < handle

    properties
        % Diplay of shock names
        ShockNames (1, :) string = string.empty(1, 0)
    end

    methods
        function this = Meta(metaReducedForm, options)
            arguments
                metaReducedForm (1, 1) meta.ReducedForm
                options.ShockNames (1, :) = string.empty(1, 0)
                options.ShockPrefix (1, 1) string = "shock_"
            end

            endogenousNames = metaReducedForm.EndogenousNames;
            numShocks = numel(endogenousNames);
            if isempty(options.ShockNames)
                this.ShockNames = options.ShockPrefix + endogenousNames;
            else
                this.ShockNames = repmat("", 1, numShocks);
                this.ShockNames(1:numShocks) = options.ShockNames(1:numShocks);
            end
        end%
    end

end

