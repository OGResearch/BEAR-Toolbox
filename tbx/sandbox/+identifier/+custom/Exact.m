
classdef Exact < identifier.custom.Base

    properties (Constant)
        CALLABLE_PREAMBLE = "@(state)"
    end

    methods (Static)
        function output = replaceCallable(input)
            output = "identifier.custom.exact" + input + "(state, ";
        end%
    end

end

