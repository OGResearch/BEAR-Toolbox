
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
            form = join(matlab, " ");
        end%

        function form = string(matlab)
            arguments
                matlab (1, 1) string
            end
            form = matlab;
        end%

        function form = number(matlab)
            arguments
                matlab (1, 1) double
            end
            form = string(matlab);
        end%

        function form = numbers(matlab)
            arguments
                matlab (1, :) double
            end
            form = string(matlab);
            form = join(form, " ");
        end%

        function form = logical(matlab)
            arguments
                matlab (1, 1) logical
            end
            form = string(matlab);
        end%

    end

end

