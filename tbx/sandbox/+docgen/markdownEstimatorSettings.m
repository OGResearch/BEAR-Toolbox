
function out = markdownEstimatorSettings()

    PATH = fullfile("quickref", "estimatorSettings.md");

    estimatorSettings = docgen.getEstimatorSettings();

    lines = string.empty(0, 1);
    lines = [
        lines
        "# Estimator settings"
        ""
        "Estimators in alphabetical order"
        ""
    ];

    estimatorNames = textual.stringify(fieldnames(estimatorSettings));
    estimatorNames = sort(estimatorNames);
    for i = 1 : numel(estimatorNames)
        lines(end+1) = "";
        lines(end+1) = "";
        lines(end+1) = "## Settings for the `" + estimatorNames(i) + "` estimator";
        lines(end+1) = "";
        lines(end+1) = "Name | Default | Description";
        lines(end+1) = "-----|--------:|------------";
        settings = estimatorSettings.(estimatorNames(i));
        settingNames = textual.stringify(fieldnames(settings));
        settingNames = sort(settingNames);
        for j = 1 : numel(settingNames)
            settingName = settingNames(j);
            setting = settings.(settingName);
            lines(end+1) = sprintf("`%s` | `%s` | %s", settingName, printSetting(setting{1}), setting{2});
        end
    end

    lines(end+1) = "";
    out = join(lines, newline());

    writematrix(out, PATH, fileType="text", quoteStrings=false);

end%


function out = printSetting(value)
    if isstring(value) || ischar(value)
        out = """" + string(value) + """";
        return
    end
    out = string(value);
end%

