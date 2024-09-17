function [startlocation, favar]=...
    gen_favar(opts, favar, informationdata,informationnames)

startdate = bear.utils.fixstring(opts.startdate);
enddate   = bear.utils.fixstring(opts.enddate);

favar = nw_favar.initfavar(favar);

% identify the position of the string corresponding to the start period
datestrings = informationnames(4:end,1);
startlocationData = find(strcmp(datestrings,startdate));
% identify the position of the string corresponding to the end period


[informationstartlocation,favar]=nw_favar.ogr_favar_gensample1(startdate,enddate,favar,informationdata,informationnames);

    if favar.transformation==1
        startlocation=informationstartlocation;
        % check is correct
    else
        startlocation=startlocationData;
    end

end