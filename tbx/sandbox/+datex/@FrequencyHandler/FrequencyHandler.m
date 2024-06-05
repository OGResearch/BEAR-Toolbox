classdef (Abstract) FrequencyHandler

    properties (Abstract, Constant)
        SdmxPattern
        SdmxLen
    end

    methods (Abstract)
        dt = datetimeFromSdmx(varargin)
    end

    methods
        function tf = matchDatetime(this, dt)
            tf = isequal(this.Format, dt.Format);
        end%

        function flag = validateSdmx(this, sdmx)
            arguments
                this
                sdmx (1, 1) string
            end
            flag = ...
                strlength(sdmx) == this.SdmxLen ...
                && ~isempty(extract(sdmx, this.SdmxPattern));
        end%
    end

end

