
function dt = span(from, until, step)

    arguments
        from (1, 1) datetime
        until (1, 1) datetime
        step (1, 1) double {mustBeInteger, mustBeMember(step, [1, -1])} = 1
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

