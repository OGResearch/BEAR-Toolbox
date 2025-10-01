function updateMetaPage(input_file,output_file, meta)
    % updateMetaPage - Update the metadata page in the User folder
    %
    % Syntax: updateMetaPage(input_file, output_file, meta)
    %
    % Inputs:
    %   input_file - Path to the input HTML file template
    %   output_file - Path to the output HTML file to be generated
    %   Meta - List of metadata settings to be included in the HTML file
    %
    % Outputs:
    %   None, but updates the HTML file with the provided metadata settings

    % Check if input_file and output_file are provided
    if nargin < 3
        error('Input file, output file, and metaList must be provided.');
    end
% updateMetaPage - Update the metadata page in the User folder
    metaList = gui.createForm(meta,"Meta Settings");
    gui.changeHtmlFile(input_file,output_file, "$Meta_settings", metaList);
end