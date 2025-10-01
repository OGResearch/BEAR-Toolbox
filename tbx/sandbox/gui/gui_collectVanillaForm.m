
function gui_collectVanillaForm(varargin)

    if nargin ~= 2
        error("Incorrect number of input arguments.");
    end

    SUBMISSION_LEAD = "?";

    submission = SUBMISSION_LEAD + extractAfter(varargin{2}, SUBMISSION_LEAD);
    formPath = { ...
        string(varargin{1}), ...
        extractBefore(string(varargin{2}), SUBMISSION_LEAD), ...
    };

    % Get information submitted by the user and cleaned up to comply with the
    % specifications
    settingsForm = gui.readFormsFile(formPath);
    cleanSubmission = gui.resolveCleanFormSubmission(submission, settingsForm);
    settingsForm = gui.updateValuesFromSubmission(settingsForm, cleanSubmission);

    % Update the settings JSON with the new values
    gui.writeFormsFile(settingsForm, formPath);

    % Repopulate the HTML with the cleaned-up settings
    gui.populateVanillaFormHTML(formPath);

    % Move on to the next page
    nextPage = gui.determineNextPage(formPath);
    nextPagePath = fullfile(".", "html", nextPage{:}) + ".html";
    if ~exist(nextPagePath, "file")
        error("Target HTML file does not exist: " + nextPagePath);
    end
    web(nextPagePath);

end%

