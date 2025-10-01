
function returnFromCommandWindow()

    TARGET_PAGE = {"html", "script", "execution.html"};
    targetPage = fullfile(".", TARGET_PAGE{:});
    bottomLine = "<a href=""matlab:web('?HTML?')"">Click here to return to the GUI</a>";
    bottomLine = replace(bottomLine, "?HTML?", targetPage);

    disp(" ");
    disp(bottomLine);
    disp(" ");

end%

