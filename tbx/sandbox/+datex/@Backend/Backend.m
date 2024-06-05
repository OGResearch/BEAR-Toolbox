classdef Backend

    properties (Constant)
        FrequencyHandlers = {
            datex.Yearly
            datex.Quarterly
            datex.Monthly
        }
    end

    methods (Static)
        function fh = getFrequencyHandlerFromDatetime(dt)
            arguments
                dt (1, 1) datetime
            end

            for i = 1 : numel(datex.Backend.FrequencyHandlers)
                fh = datex.Backend.FrequencyHandlers{i};
                if fh.matchDatetime(dt)
                    return
                end
            end
            fh = NaN;
        end%

        function fh = getFrequencyHandlerFromFrequency(freq)
            arguments
                freq (1, 1) double
            end

            for i = 1 : numel(datex.Backend.FrequencyHandlers)
                fh = datex.Backend.FrequencyHandlers{i};
                if fh.Frequency == freq
                    return
                end
            end
            fh = NaN;
        end%


        function fh = getFrequencyHandlerFromSdmx(sdmx)
            arguments
                sdmx (1, 1) string
            end

            for i = 1 : numel(datex.Backend.FrequencyHandlers)
                fh = datex.Backend.FrequencyHandlers{i};
                if fh.validateSdmx(sdmx)
                    return
                end
            end
            fh = NaN;
        end%
    end

end

