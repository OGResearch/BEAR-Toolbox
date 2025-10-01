
classdef Base

    properties (Constant, Abstract)
        CALLABLE_PREAMBLE (1, 1) string
    end

    methods (Static, Abstract)
        output = replaceCallable(input)
    end



    properties
        InputString (1, 1) string
        Callable
    end

    methods
        function this = Base(inputString)
            arguments
                inputString (1, 1) string
            end
            inputString = strip(inputString);
            this.InputString = inputString;
            callableString = this.parseCallable(inputString, @this.replaceCallable);
            this.Callable = str2func(this.CALLABLE_PREAMBLE + callableString);
        end%
    end

    methods (Static)
        function callableString = parseCallable(inputString, replaceCallable)
            arguments
                inputString (1, 1) string
                replaceCallable (1, 1) function_handle
            end
            callableString = regexprep(inputString, "\$(\w+)\(", "${replaceCallable($1)}");
        end%
    end

end

