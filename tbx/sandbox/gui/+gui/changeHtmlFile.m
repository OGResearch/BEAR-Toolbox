
function changeHtmlFile(inputFilename, outputFilename, oldText, newText)

    x = fileread(inputFilename);
    x = replace(x,oldText, newText);
    writematrix(x, outputFilename, fileType="text", quoteStrings=false);
    web(outputFilename);

end%

