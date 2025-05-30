
function clean = resolveCleanFormSubmission(submission, specs)

    arguments
        submission (1, 1) string
        specs (1, :) struct
    end

    ftm = gui.FormToMatlab();
    raw = gui.resolveRawFormSubmission(submission);
    keys = textual.fields(raw);

    clean = struct();
    for key = keys
        rawValue = raw.(key);
        type = string(specs.(key).type);
        %try
            cleanValue = ftm.(type)(rawValue);
        %catch
        %    error("Error processing this value: %s", key);
        %end
        clean.(key) = cleanValue;
    end

    % Exception: Missing "logical" results in false
    specsKeys = reshape(string(fieldnames(specs)), 1, []);
    submissionKeys = reshape(string(fieldnames(clean)), 1, []);
    for key = setdiff(specsKeys, submissionKeys)
        type = string(specs.(key).type);
        if type == "logical"
            clean.(key) = false;
        end
    end

    % Report keys not delivered by form
    submissionKeys = reshape(string(fieldnames(clean)), 1, []);
    missingKeys = setdiff(specsKeys, submissionKeys);
    if ~isempty(missingKeys)
        error("Form failed to deliver the following values: %s", join(missingKeys, " "));
    end

end%

