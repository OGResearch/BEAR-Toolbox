function [data_endo, favar] = get_favar_endo(opts, data_endo, favar, informationdata,informationnames)

    startdate = bear.utils.fixstring(opts.startdate);
    enddate   = bear.utils.fixstring(opts.enddate);
    
    favar = favars.initfavar(favar);
    
    % identify the position of the string corresponding to the start period
    datestrings = informationnames(4:end,1);
    startlocationData = find(strcmp(datestrings,startdate));
    % identify the position of the string corresponding to the end period
        
    [informationstartlocation,favar] = favars.ogr_favar_gensample1(startdate,enddate,favar,informationdata,informationnames);
    
    if favar.transformation==1
        startlocation=informationstartlocation;
        % check is correct
    else
        startlocation=startlocationData;
    end

    varendo    = bear.utils.fixstring(opts.varendo);
    findspace  = isspace(varendo);
    locspace   = find(findspace);
    delimiters = [0 locspace numel(varendo)+1];
    % count the number of endogenous variables
    % first count the number of spaces
    nspace = sum(findspace(:)==1);
    % each space is a separation between two variable names, so there is one variable more than the number of spaces
    numendo = nspace+1;
    % now finally identify the endogenous
    endo = cell(numendo,1);
    
    for ii = 1:numendo
        endo{ii,1} = varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
    end
    
    flag_factor = contains(endo,'factor');
    variablestrings = endo(~flag_factor);
    numendo = numel(endo);
    lags = opts.lags;
    
    [data,variablestrings,favar] = bear.favar_gensample2(data_endo,endo,variablestrings,startlocation,lags,favar);
    
    % identify the position of the strings corresponding to the endogenous variables
    % for each variable, find the corresponding string
    data_endo=[];
    for ii=1:numendo
        % check first that the variable ii in endo appears in the list of variable strings
        % if not, the variable is unknown: return an error
        var=endo{ii,1};
        check=find(strcmp(variablestrings,var));
        if isempty(check)==1
            message=['Error: endogenous variable ' var ' cannot be found on the excel data spreadsheet.'];
            error('BEARmain:gensample:EndoVarNotFound', message);
        end
        % if the variable is known, go on
        endolocation(ii,1) = find(strcmp(variablestrings,endo(ii,1)));
        data_endo=[data_endo data(:,endolocation(ii,1))];
    end

    if favar.transformation==1
        % correct order of transformationindex_endo
        favar.transformationindex_endo=[];
        for ii=1:size(endo,1)
            favar.transformationindex_endo = [favar.transformationindex_endo favar.transformationindex_endo_temp(:,endolocation(ii,1))];
        end
    end

    % correct order of stddev
    favar.data_exfactors_stddev=[];
    for ii=1:size(endo,1)
        favar.data_exfactors_stddev = [favar.data_exfactors_stddev favar.data_exfactors_stddev_temp(:,endolocation(ii,1))];
    end
        
    % IRF shock to plot
    if favar.IRFplot==1
        favar.IRF.npltXshck=size(favar.IRF.pltXshck,1);
        if IRFt==1||IRFt==2||IRFt==3
            plotXshock_indexlogical=ismember(endo,favar.IRF.pltXshck);
            favar.IRF.plotXshock_index=find(plotXshock_indexlogical==1)';
            if favar.IRF.npltXshck==0
                % error if no shock to plot is found, otherwise code crashes at a later stage
                message=['Error: Shock(' favar.IRF.npltXshck ') cannot be found.'];
                error('BEARmain:gensample:favar_IRF_npltXshck_error',message);
            end
        end
        % for IRFt 4 & 6 this step is done in loadsignres
    end
    
    % rotate Factors, compute new loadings for onestep, twostep estimation
    [data_endo,favar] = bear.favar_gensample3(data_endo,favar);
end


