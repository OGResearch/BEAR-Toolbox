
function copyCustomHTML(sourceFilename, targetFilename, varargin)

    x = fileread(sourceFilename);

    for i = 1 : 2 : numel(varargin)
        oldText = varargin{i};
        newText = varargin{i+1};
        x = replace(x, oldText, newText);
    end

    writematrix(x, targetFilename, fileType="text", quoteStrings=false);

end%

