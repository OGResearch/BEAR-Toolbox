
classdef Config

    properties
        DataSource_Format (1, 1) string
        DataSource_FilePath (1, 1) string

        ReducedFormMeta_Units (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_EndogenousConcepts (1, :) string {mustBeNonempty} = ""
        ReducedFormMeta_ExogenousNames (1, :) string
        ReducedFormMeta_HasIntercept (1, 1) logical
        ReducedFormMeta_Order (1, 1) double {mustBeInteger, mustBePositive} = 1
        ReducedFormMeta_EstimationStart (1, 1) string
        ReducedFormMeta_EstimationEnd (1, 1) string

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
    end

end

