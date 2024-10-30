
classdef Config < handle

    properties
        DataSource_Format (1, 1) string
        DataSource_FilePath (1, 1) string

        Tasks_Percentiles (1, :) cell
        Tasks_ParameterTables (1, :) cell
        Tasks_AsymptoticMeanTables (1, :) cell
        Tasks_ResidualEstimates (1, :) cell
        Tasks_UnconditionalForecast (1, :) cell
        Tasks_ShockEstimates (1, :) cell
        Tasks_ShockResponses (1, :) cell
        Tasks_ConditionalForecast (1, :) cell
        Tasks_SaveResults (1, :) cell
        Tasks_SaveConfig (1, :) cell

        ReducedFormMeta_Units (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_EndogenousConcepts (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_ExogenousNames (1, :) string
        ReducedFormMeta_HasIntercept (1, 1) logical
        ReducedFormMeta_Order (1, 1) double {mustBeInteger, mustBePositive} = 1
        ReducedFormMeta_EstimationStart (1, 1) string
        ReducedFormMeta_EstimationEnd (1, 1) string
        ReducedFormMeta_NumDraws (1, 1) double {mustBeInteger, mustBePositive} = 1000

        Estimator_Name (1, 1) string
        Estimator_Settings (1, :) cell

        StructuralMeta_ShockConcepts (1, :) string
        StructuralMeta_IdentificationHorizon (1, 1) double {mustBeInteger, mustBePositive} = 1
    end


    methods
        function span = createEstimationSpan(this)
            startPeriod = datex.fromSdmx(this.ReducedFormMeta_EstimationStart);
            endPeriod = datex.fromSdmx(this.ReducedFormMeta_EstimationEnd);
            span = datex.span(startPeriod, endPeriod);
        end%


        function metaR = createReducedFormMetaObject(this)
            estimationSpan = this.createEstimationSpan();
            metaR = meta.ReducedForm( ...
                endogenous=this.ReducedFormMeta_EndogenousConcepts ...
                , units=this.ReducedFormMeta_Units ...
                , exogenous=this.ReducedFormMeta_ExogenousNames ...
                , order=this.ReducedFormMeta_Order ...
                , intercept=this.ReducedFormMeta_HasIntercept ...
                , estimationSpan=estimationSpan ...
            );
        end%


        function metaS = createStructuralMetaObject(this, metaR)
            if nargin < 2
                metaR = this.createReducedFormMetaObject();
            end
            metaS = meta.Structural( ...
                metaR ...
                , identificationHorizon=this.StructuralMeta_IdentificationHorizon ...
                , shockConcepts=this.StructuralMeta_ShockConcepts ...
            );
        end%
    end

end

