classdef Yearly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.YEARLY
        Format = "uuuu"
        SdmxPattern = digitsPattern(4)
        SdmxLen = 4
    end

    methods
        function dt = datetimeFromSdmx(this, sdmx)
            arguments
                this
                sdmx (1, 1) string
            end
            sdmx = extractBetween(sdmx, 1, this.SdmxLen);
            dt = this.construct(double(sdmx));
        end%
    end

end

