
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
        try
            value = ftm.(type)(submissionValue);
        catch
            error("Error processing this value: %s", key);
        end
        result.(key) = value;
    end

    % Exception: Missing "logical" results in false
    specsKeys = reshape(string(fieldnames(specs)), 1, []);
    submissionKeys = reshape(string(fieldnames(result)), 1, []);
    for key = setdiff(specsKeys, submissionKeys)
        type = string(specs.(key).type);
        if type == "logical"
            result.(key) = false;
        end
    end

    % Report keys not delivered by form
    submissionKeys = reshape(string(fieldnames(result)), 1, []);
    missingKeys = setdiff(specsKeys, submissionKeys);
    if ~isempty(missingKeys)
        error("Form failed to deliver the following values: %s", join(missingKeys, " "));
    end

end%
