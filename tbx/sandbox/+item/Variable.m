
classdef Variable < item.Abstract

    properties (SetAccess = protected, Hidden)
        Name (1, 1) string
    end

    properties (SetAccess = protected)
        NumColumns = 1
    end

    properties (Dependent)
        DisplayName
    end

    methods
        function this = Variable(name)
            this.Name = name;
        end%

        function outArray = getData(this, inTable, periods, options)
            arguments
                this
                inTable timetable
                periods (1, :) datetime
                options.Variant (1, 1) double = 1
            end

            outArray = tablex.getData( ...
                inTable, this.Name, periods ...
                , variant=options.Variant ...
            );

        end%

        function name = get.DisplayName(this)
            name = this.Name;
        end%
    end

end
