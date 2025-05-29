
function result = resolveFormSubmission(submission, specs)

    arguments
        submission (1, 1) string
        specs (1, :) struct
    end

    LEAD_CHAR = "?";
    SEPARATOR = "&";
    ASSIGNMENT = "=";
    ftm = gui.FormToMatlab;

    submission = erase(submission, LEAD_CHAR);
    entries = reshape(string(split(submission, SEPARATOR)), 1, []);

    result = struct();
    for n = entries
        pair = split(n, ASSIGNMENT);
        key = strip(pair(1));
        submissionValue = strip(pair(2));
        type = string(specs.(key).type);
        %try
            value = ftm.(type)(submissionValue);
        %catch
        %    error("Error processing value for %s", key);
        %end
        result.(key) = value;
    end

end%

