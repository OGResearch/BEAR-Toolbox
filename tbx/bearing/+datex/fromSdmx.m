

function dt = fromSdmx(inputStrings)

    inputStrings = string(inputStrings);
    fh = datex.Backend.getFrequencyHandlerFromSdmx(inputStrings(1));
    dt = datetime.empty(0, 1);
    dt.Format = fh.Format;
    for i = 1 : numel(inputStrings)
        dt(i, 1) = fh.datetimeFromSdmx(inputStrings(i));
    end

end%
