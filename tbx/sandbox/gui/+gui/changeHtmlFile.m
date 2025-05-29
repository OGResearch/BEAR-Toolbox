function changeHtmlFile(input_filename, output_filename, oldText, newText)
    x = fileread(input_filename);
    x = replace(x,oldText, newText);
    writematrix(x, output_filename, fileType="text", quoteStrings=false);
    web(output_filename);
end