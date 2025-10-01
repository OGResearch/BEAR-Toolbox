
function updateMetaPage(inputFile, outputFile, meta)

    arguments
        inputFile (1,1) string
        outputFile (1,1) string
        meta (1,1) struct
    end

    % updateMetaPage - Update the metadata page in the User folder
    %
    % Syntax: updateMetaPage(inputFile, outputFile, meta)
    %
    % Inputs:
    %   inputFile - Path to the input HTML file template
    %   outputFile - Path to the output HTML file to be generated
    %   Meta - List of metadata settings to be included in the HTML file
    %
    % Outputs:
    %   None, but updates the HTML file with the provided metadata settings

    form = gui.createForm(meta, action="collectMeta");
    % TODO: $Meta_settings --> $META_SETTINGS_FORM
    gui.changeHtmlFile(inputFile,outputFile, "$Meta_settings", form);

end%

