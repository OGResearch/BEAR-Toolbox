
% meta.Structural  Meta data for structural VAR objects

classdef Structural < handle

    properties
        % Diplay of shock names
        ShockNames (1, :) string

        % IdentificationHorizon  Number of periods for which the VMA
        % representation will be calculated
        IdentificationHorizon (1, 1) double
    end


    properties (Dependent)
        NumShocks
    end


    methods

        function this = Structural(metaR, options)
            arguments
                metaR (1, 1) meta.ReducedForm
                %
                options.identificationHorizon (1, 1) double {mustBeInteger, mustBePositive}
                options.shockConcepts (1, :) string = string.empty(1, 0)
            end
            %
            if ~isempty(options.shockConcepts)
                shockConcepts = options.shockConcepts;
            else
                shockConcepts = meta.autogenerateShockConcepts(metaR.NumEndogenousConcepts);
            end
            names = string.empty(1, 0);
            for unit = metaR.Units
                names = [names, meta.concatenate(unit, shockConcepts)];
            end
            this.ShockNames = names;
            %
            this.IdentificationHorizon = options.identificationHorizon;
            %
            if numel(this.ShockNames) ~= metaR.NumEndogenousNames
                error("Number of shock names must match number of endogenous variables");
            end
        end%


        function out = get.NumShocks(this)
            out = numel(this.ShockNames);
        end%

    end

end

