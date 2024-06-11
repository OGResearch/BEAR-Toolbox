
classdef Structural < handle

    properties
        Meta
        ReducedForm
        Identification
        Presampled
    end

    properties (Dependent)
        NumPresampled (1, 1) double
    end

    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    methods
        function this = Structural(options)
            arguments
                options.Meta (1, 1) model.Structural.Meta
                options.ReducedForm (1, 1) model.ReducedForm
                options.Identification (1, 1) identification.Base
            end

            this.Meta = options.Meta;
            this.ReducedForm = options.ReducedForm;
            this.Identification = options.Identification;
        end%
    end

end

