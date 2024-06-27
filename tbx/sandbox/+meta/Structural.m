
% meta.Structural  Meta data for structural VAR objects

classdef Structural < handle

    properties
        % Diplay of shock names
        ShockNames (1, :) string = string.empty(1, 0)
    end

    methods
        function this = Structural(options)
            arguments
                options.ShockNames (1, :) = string.empty(1, 0)
            end
            this.ShockNames = reshape(string(options.ShockNames), 1, [ ]);
        end%
    end

end

