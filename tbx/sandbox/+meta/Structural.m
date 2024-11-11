
% meta.Structural  Meta data for structural VAR objects

classdef Structural < meta.ReducedForm

    properties
        % Reduced form meta
        ReducedForm meta.ReducedForm
        %
        % Diplay of shock names
        ShockConcepts (1, :) string
        %
        % IdentificationHorizon  Number of periods for which the VMA
        % representation will be calculated
        IdentificationHorizon (1, 1) double
    end


    properties (Dependent)
        ShockNames
        NumShockConcepts
        NumShocks
        NumShockNames
    end


    methods

        function this = Structural(metaR, options)
            arguments
                metaR (1, 1) meta.ReducedForm
                options.identificationHorizon (1, 1) double {mustBeInteger, mustBePositive}
                options.shockConcepts (1, :) string = string.empty(1, 0)
            end
            this = this@meta.ReducedForm( ...
                endogenousConcepts=metaR.EndogenousConcepts, ...
                estimationSpan=metaR.EstimationSpan, ...
                exogenousNames=metaR.ExogenousNames, ...
                units=metaR.Units, ...
                order=metaR.Order, ...
                intercept=metaR.HasIntercept ...
            );
            this.populateShockConcepts(options);
            this.IdentificationHorizon = options.identificationHorizon;
            if this.NumShockNames ~= metaR.NumEndogenousNames
                error("Number of shock names must match number of endogenous variables");
            end
        end%

    end


    methods
        function populateShockConcepts(this, options)
            if ~isempty(options.shockConcepts)
                this.ShockConcepts = options.shockConcepts;
            else
                this.ShockConcepts = meta.autogenerateShockConcepts(metaR.NumEndogenousConcepts);
            end
        end%

        function copyOver(this, metaR)
            mc = metaclass(metaR);
            for p = reshape(mc.PropertyList, 1, [])
                if ~p.Dependent
                    this.(p.Name) = metaR.(p.Name);
                end
            end
        end%
    end

end

