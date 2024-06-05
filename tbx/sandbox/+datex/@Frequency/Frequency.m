% Enumerated type for frequency of data
%

classdef Frequency < double

    enumeration
        YEARLY(1)
        HALFYEARLY(2)
        QUARTERLY(4)
        MONTHLY(12)
        WEEKLY(52)
        DAILY(365)
    end

end

