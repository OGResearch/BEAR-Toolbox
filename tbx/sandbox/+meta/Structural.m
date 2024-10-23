
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

        function this = Structural(redMeta, options)
            arguments
                redMeta (1, 1) meta.ReducedForm
                %
                options.identificationHorizon (1, 1) double {mustBeInteger, mustBePositive}
                options.shockNames (1, :) string = string.empty(1, 0)
            end
            %
            if ~isempty(options.shockNames)
                this.ShockNames = options.shockNames;
            else
                this.ShockNames = meta.autogenerateShockNames(redMeta.NumEndogenousNames);
            end
            %
            this.IdentificationHorizon = options.identificationHorizon;
            %
            if numel(this.ShockNames) ~= redMeta.NumEndogenousNames
                error("Number of shock names must match number of endogenous variables");
            end
        end%


        function out = get.NumShocks(this)
            out = numel(this.ShockNames);
        end%

    end

end

