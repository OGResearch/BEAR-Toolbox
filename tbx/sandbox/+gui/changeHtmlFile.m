function changeHtmlFile(filename, oldText, newText)
    x = fileread(filename);
    x = replace(x,oldText, newText);
    writematrix(x, filename, fileType="text", quoteStrings=false);
    web(filename);
end