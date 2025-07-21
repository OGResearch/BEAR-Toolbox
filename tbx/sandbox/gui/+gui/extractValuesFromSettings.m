
function values = extractValuesFromSettings(settings)

    values = struct();
    for n = textual.fields(settings)
        values.(n) = settings.(n).default;
    end

end%

