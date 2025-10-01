
function raw = resolveRawFormSubmission(submission)

    arguments
        submission (1, 1) string
    end

    LEAD_CHAR = "?";
    SEPARATOR = "&";
    ASSIGNMENT = "=";

    submission = erase(submission, LEAD_CHAR);
    entries = reshape(string(split(submission, SEPARATOR)), 1, []);

    raw = struct();
    for n = entries
        pair = split(n, ASSIGNMENT);
        key = strip(pair(1));
        rawValue = strip(pair(2));
        raw.(key) = rawValue;
    end

end%

