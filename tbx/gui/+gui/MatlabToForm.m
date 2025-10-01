
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
            elseif isnan(matlab)
                form = "NaN";
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
            form(isnan(matlab)) = "NaN";
            form = join(form, " ");
        end%

        function form = logical(matlab)
            form = gui.isTrue(matlab);
        end%

        function form = logicals(matlab)
            form = repmat("", 1, numel(matlab));
            for i = 1:numel(matlab)
                form(i) = string(gui.isTrue(matlab(i)));
            end
            form = join(form, " ");
        end%

        function form = date(matlab)
            arguments
                matlab (1, 1) string
            end
            form = strip(matlab);
        end%

        function form = dates(matlab)
            arguments
                matlab (:, :) string
            end
            form = reshape(strip(matlab), 1, []);
            form = join(form, " ");
        end%

        function form = span(matlab)
            arguments
                matlab (1, 2) string
            end
            form = join(strip(matlab), " ");
        end%

        function form = filename(matlab)
            arguments
                matlab (1, 1) string
            end
            form = strip(matlab);
        end%

    end

end

