
classdef Verifiable < base.identifier.custom.Base

    properties (Constant)
        CALLABLE_PREAMBLE = "@(state)"
    end

    methods (Static)
        function output = replaceCallable(input)
            output = "base.identifier.custom.verify" + input + "(state, ";
        end%
    end

end

