classdef Quarterly < datex.Regular

    properties (Constant)
        Frequency = datex.Frequency.QUARTERLY
        Format = "uuuu-'Q'Q"
        SdmxPattern = caseInsensitivePattern(digitsPattern(4) + "-Q" + digitsPattern(1))
        SdmxLen = 7
    end

    methods
        function dt = datetimeFromSdmx(this, sdmx)
            arguments
                this
                sdmx (1, 1) string
            end
            sdmx = extractBetween(sdmx, 1, this.SdmxLen);
            splitSdmx = split(sdmx, "-Q");
            dt = this.construct(double(splitSdmx(1)), double(splitSdmx(2)));
        end%
    end

end

