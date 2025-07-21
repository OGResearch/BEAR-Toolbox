
function changeHtmlFile(inputFilename, outputFilename, varargin)

    x = fileread(inputFilename);

    for i = 1 : 2 : numel(varargin)
        oldText = varargin{i};
        newText = varargin{i+1};
        x = replace(x, oldText, newText);
    end

    writematrix(x, outputFilename, fileType="text", quoteStrings=false);

end%

