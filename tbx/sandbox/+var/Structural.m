
classdef Structural

    properties
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

    function this = Structural(options)
        arguments
            options.ReducedForm (1, 1) var.ReducedForm
            options.Identifier (1, 1) var.AbstractIdentifier
        end
        this.ReducedForm = options.ReducedForm;
        this.Identifier = options.Identifier;
    end%

end

