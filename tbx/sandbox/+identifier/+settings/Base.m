
% identifier.settings.Base  Common indentification scheme settings

classdef (CaseInsensitiveProperties=true) Base < settings.Base

    properties
        TimeVariant = false
        StdVec (1, :) double = 1
    end

end

