
classdef MatlabToForm

    methods (Static)

        function form = name(matlab)
            arguments
                matlab (1, 1) string
            end
            form = matlab;
        end%

        function form = names(matlab)
            arguments
                matlab (1, :) string
            end
            if isempty(matlab)
                form = "";
                return
            end
            form = join(matlab, " ");
        end%

        function form = string(matlab)
            arguments
                matlab (1, 1) string
            end
            if isempty(matlab)
                form = "";
            else
                form = matlab;
            end
        end%

        function form = number(matlab)
            arguments
                matlab double {mustBeScalarOrEmpty(matlab)} = []
            end
            if isempty(matlab)
                form = "";
            else
                form = string(matlab);
            end
        end%

        function form = numbers(matlab)
            arguments
                matlab (1, :) double = []
            end
            if isempty(matlab)
                form = "";
                return
            end
            form = string(matlab);
            form = join(form, " ");
        end%

        function form = logical(matlab)
            form = isequal(matlab, true) || isequal(matlab, 1) || isequal(matlab, "true") || isequal(matlab, "1");
        end%

    end

end

