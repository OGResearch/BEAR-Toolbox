
% meta.Structural  Meta data for structural VAR objects

classdef Structural < handle

    properties
        % Diplay of shock names
        ShockNames (1, :) string
    end

    properties (Dependent)
        NumShocks
    end

    methods
        function this = Structural(shockNames)
            arguments
                shockNames (1, :)
            end
            this.ShockNames = reshape(string(shockNames), 1, []);
        end%

        function num = get.NumShocks(this)
            num = numel(this.ShockNames);
        end%
    end

end

