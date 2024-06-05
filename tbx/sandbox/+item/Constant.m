
classdef Constant < item.AbstractFixed

    properties (SetAccess = protected)
        NumColumns = 1
    end

    methods
        function dataColumns = getData(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :) datetime
                options.Variant (1, 1) double = 1
            end

            numPeriods = numel(periods);
            dataColumns = ones(numPeriods, 1);
        end%
    end

end

