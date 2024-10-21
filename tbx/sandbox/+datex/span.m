
function dt = span(from, until, step)

    arguments
        from (1, 1)
        until (1, 1)
        step (1, 1) double {mustBeInteger, mustBeMember(step, [1, -1])} = 1
    end

    if isstring(from)
        from = datex.fromSdmx(from);
    end

    if isstring(until)
        until = datex.fromSdmx(until);
    end

    handler = datex.Backend.getFrequencyHandlerFromDatetime(from);
    untilHandler = datex.Backend.getFrequencyHandlerFromDatetime(until);

    if ~isequal(handler, untilHandler)
        error("Start and end periods for a time span must be datetimes of the same time frequency.");
    end

    fromSerial = handler.serialFromDatetime(from);
    untilSerial = handler.serialFromDatetime(until);
    spanSerial = fromSerial : step : untilSerial;
    dt = handler.datetimeFromSerial(spanSerial);

end%

