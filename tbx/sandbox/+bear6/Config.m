
classdef Config

    properties
        DataSource_Format (1, 1) string
        DataSource_FilePath (1, 1) string

        Tasks_Percentiles (1, :) double {mustBeNonempty} = [5, 50, 95]

        ReducedFormMeta_Units (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_EndogenousConcepts (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_ExogenousNames (1, :) string
        ReducedFormMeta_HasIntercept (1, 1) logical
        ReducedFormMeta_Order (1, 1) double {mustBeInteger, mustBePositive} = 1
        ReducedFormMeta_EstimationStart (1, 1) string
        ReducedFormMeta_EstimationEnd (1, 1) string

        Estimator_Name (1, 1) string
        Estimator_Settings (1, :) cell

        StructuralMeta_ShockConcepts (1, :) string
        StructuralMeta_IdentificationHorizon (1, 1) double {mustBeInteger, mustBePositive} = 1
    end


    properties (Dependent)
        ReducedFormMeta_EstimationSpan
    end


    methods
        function out = get.ReducedFormMeta_EstimationSpan(this)
            startPeriod = datex.fromSdmx(this.ReducedFormMeta_EstimationStart);
            endPeriod = datex.fromSdmx(this.ReducedFormMeta_EstimationEnd);
            out = datex.span(startPeriod, endPeriod);
        end%


        function metaR = createReducedFormMetaObject(this)
            metaR = meta.ReducedForm( ...
                endogenous=this.ReducedFormMeta_EndogenousConcepts ...
                , units=this.ReducedFormMeta_Units ...
                , exogenous=this.ReducedFormMeta_ExogenousNames ...
                , order=this.ReducedFormMeta_Order ...
                , intercept=this.ReducedFormMeta_HasIntercept ...
                , estimationSpan=this.ReducedFormMeta_EstimationSpan ...
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

