classdef Monthly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.MONTHLY
        Format = "uuuu-MM"
        SdmxPattern = digitsPattern(4) + "-" + digitsPattern(2)
        SdmxLen = 7
    end

    methods
        function dt = datetimeFromSdmx(this, sdmx)
            arguments
                this
                sdmx (1, 1) string
            end
            sdmx = extractBetween(sdmx, 1, this.SdmxLen);
            splitSdmx = split(sdmx, "-");
            dt = this.construct(double(splitSdmx(1)), double(splitSdmx(2)));
        end%
    end

end

