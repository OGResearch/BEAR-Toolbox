
classdef Verifiable < identifier.custom.Base

    properties (Constant)
        CALLABLE_PREAMBLE = "@(state)"
    end

    methods (Static)
        function output = replaceCallable(input)
            output = "identifier.custom.verify" + input + "(state, ";
        end%
    end

end

