function dt = shift(dt, by)

    if isequal(by, 0)
        return
    end

    fh = datex.Backend.getFrequencyHandlerFromDatetime(dt);
    serial = fh.serialFromDatetime(dt);
    serial = serial + by;
    dt = fh.datetimeFromSerial(serial);

end%

