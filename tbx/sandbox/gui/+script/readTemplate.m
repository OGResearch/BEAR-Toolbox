
function code = readTemplate(templateName)

    arguments
        templateName (1, 1) string
    end

    templateFolder = script.getTemplateFolder();
    preambleFile = fullfile(templateFolder, templateName + ".m");
    code = textual.read(preambleFile);

end%

