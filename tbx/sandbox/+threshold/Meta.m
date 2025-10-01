
% model.Meta  Meta information about reduced-form and structural models

classdef Meta < baseWithDummies.Meta

    % Reduced-form model meta information
    properties (SetAccess=protected)
        %
        % ThresholdVarName  Name of variable identifying the regime
        ThresholdVarName (1, 1) string 
    end


    methods
        function this = Meta(options)

        arguments

            options.endogenousConcepts (1, :) string {mustBeNonempty}
            options.estimationSpan (1, :) datetime {mustBeNonempty}
    
            options.exogenousNames (1, :) string = string.empty(1, 0)
            options.units (1, :) string = ""
            options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
            options.intercept (1, 1) logical = true
            options.shockConcepts (1, :) string = string.empty(1, 0)
            options.shocks (1, :) string = string.empty(1, 0)
            options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
    
            options.thresholdVarName (1, :) string = string.empty(1, 0)
        end

            this@baseWithDummies.Meta( ...
                'endogenousConcepts', options.endogenousConcepts, ...
                'estimationSpan', options.estimationSpan, ...
                'exogenousNames', options.exogenousNames, ...
                'units', options.units, ...
                'order', options.order, ...
                'intercept', options.intercept, ...
                'shockConcepts', options.shockConcepts, ...
                'shocks', options.shocks, ...
                'identificationHorizon', options.identificationHorizon ...
            );

            this.ThresholdVarName = options.thresholdVarName;

        end% 

    end
end

