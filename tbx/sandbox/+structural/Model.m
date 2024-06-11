
classdef Model < handle

    properties
        Meta
        ReducedForm
        Identifier
        Presampled
    end

    properties (Dependent)
        NumPresampled (1, 1) double
    end

    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    methods
        function this = Model(options)
            arguments
                options.Meta (1, 1) structural.Meta
                options.ReducedForm (1, 1) reducedForm.Model
                options.Identifier (1, 1) structural.AbstractIdentifier
            end

            this.Meta = options.Meta;
            this.ReducedForm = options.ReducedForm;
            this.Identifier = options.Identifier;
        end%
    end

end

