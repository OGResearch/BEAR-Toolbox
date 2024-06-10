function [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,...
    data_exo_a,data_exo_p,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate, endo_ix]=...
    gensample_endo(opts)

pref = struct('excelFile', opts.excelFile, ...
    'results_path', opts.results_path, ...
    'results_sub', opts.results_sub, ...
    'results', opts.results, ...
    'plot', opts.plot, ...
    'workspace', opts.workspace);


VARtype = opts.VARtype;
startdate=bear.utils.fixstring(opts.startdate);
enddate=bear.utils.fixstring(opts.enddate);

Fstartdate = bear.utils.fixstring(opts.Fstartdate);
Fenddate   = bear.utils.fixstring(opts.Fenddate);
[endo, exo] = nw_favar.endo_exo(opts);

endo_ix = ~contains(endo,'factor');
endo = endo(endo_ix);
numendo = numel(endo);

lags = opts.lags;
F = opts.F;
CF = opts.CF;

% Phase 1: data loading and error checking

% first read the data from Excel
[data,names]=xlsread(pref.excelFile,'data');

% identify the date strings
datestrings=names(2:end,1);
% identify the position of the string corresponding to the start period
startlocationData=find(strcmp(datestrings,startdate));
% identify the position of the string corresponding to the end period
endlocation=find(strcmp(datestrings,enddate));
startlocation=startlocationData;

% save the whole sample temporarily
data1=data;
% adjust data to startdate and enddate
% data1=data(startlocationData:endlocation,:);
data=data(startlocationData:endlocation,:);

% identify the variable strings, endogenous and exogenous
variablestrings=names(1,2:end);

% if either the start date or the date date is not recognised, return an error message
if isempty(startlocation)
    error('bear:BEARmain:UnknownStartDate', ...
        'Error: unknown start date for the sample. Please check your sample start date (remember that names are case-sensitive).');
elseif isempty(endlocation)
    error('bear:BEARmain:UnknownEndDate', ...
        'Error: unknown end date for the sample. Please check your sample end date (remember that names are case-sensitive).');
end
% also, if the start date is posterior to the end date, obviously return an error
if startlocation>=endlocation==1
    error('bear:BEARmain:InconsistentStartEndDates', ...
        'Error: inconsistency between the start and end dates. The start date must be anterior to the end date.');
end

% identify the position of the strings corresponding to the endogenous variables
% for each variable, find the corresponding string
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
    endolocation(ii,1)=find(strcmp(variablestrings,endo(ii,1)));
end

% identify the position of the strings corresponding to the exogenous variables
% proceed similarly to the endogenous variables, but account for the fact that exogenous may be empty
% so check first whether there are exogenous variables altogether
if isempty(exo)
    numexo=0;
else
    % if not empty, repeat what has been done with the exogenous
    numexo=size(exo,1);
    % for each variable, find the corresponding string
    for ii=1:numexo
        % check first that the variable ii in endo appears in the list of variable strings
        % if not, the variable is unknown: return an error
        var=exo{ii,1};
        check=find(strcmp(variablestrings,var));
        if isempty(check)==1
            message=['Error: exogenous variable ' var ' cannot be found on the excel data spreadsheet.'];
            error('BEARmain:gensample:ExoVarNotFound', message);
        end
        % if the variable is known, go on
        exolocation(ii,1)=find(strcmp(variablestrings,exo(ii,1)));
    end
end

% Phase 2: creation of the data matrices data_endo and data_exo

% now create the matrix of endogenous variables for the estimation sample
% it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
data_endo=[];
% loop over endogenous variables
for ii=1:numendo
    data_endo=[data_endo data(:,endolocation(ii,1))];
end

% Similarly, create the matrix of exogenous variables for the estimation sample
data_exo=[];
for ii=1:numexo
%     data_exo=[data_exo data(startlocation:endlocation,exolocation(ii,1))];
    data_exo=[data_exo data(:,exolocation(ii,1))];
end

%% Bens check for missing values in exo and endo
[t,g]=size(data_endo);
for ii=1:t
    for jj=1:g
        temp=data_endo(ii,jj);
        if (temp<=inf)==0
            % identify the variable and the date %%%%% why is this commented
            %       NaNvariable=names{1,jj+1};
            %       NaNdate=names{ii+1,1};
            %       message=['Error: variable ' NaNvariable ' at date ' NaNdate ' (and possibly other sample entries) is identified as NaN. Please check your Excel spreadsheet: entry may be blank or non-numerical.'];
            %       msgbox(message);
            error('programme termination: An endogenous variable entry is missing');
        end
    end
end
%
%
[t,g]=size(data_exo);
for ii=1:t
    for jj=1:g
        temp=data_exo(ii,jj);
        if (temp<=inf)==0
            error('programme termination: An exogenous variable entry is missing');
        end
    end
end


% Phase 3: determination of the position of the forecast start and end periods

% if both unconditional and conditional forecasts were not selected, there is no need for all the forecast-specific matrices: simply return empty matrices
if (VARtype==1 && F==0) || ((VARtype==2 || VARtype==3 || VARtype==5 || VARtype==6 ) && (F==0 && CF==0))
    data_endo_a=[];
    data_exo_a=[];
    data_exo_p=[];
    Fperiods=[];
    Fcomp=[];
    Fcperiods=[];
    data_endo_c=[];
    data_endo_c_lags=[];
    data_exo_c=[];
    data_exo_c_lags=[];
    Fcenddate=[];
    
    % if forecast were selected, create all the required elements
else
    datestrings=names(2:end,1);
    % identify the location of the last period in the dataset
    dataendlocation=size(datestrings,1);

    [Fstartlocation,Fperiods] = nw_favar.get_fcast_rng(datestrings,opts);
    Fendlocation = Fstartlocation + Fperiods -1;
    
    data=data1;
    % now create the matrix of endogenous variables for the pre-forecast period
    % it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
    data_endo_a=[];
    % loop over endogenous variables
    for ii=1:numendo
        data_endo_a=[data_endo_a data(1:Fstartlocation-1,endolocation(ii,1))];
    end
    % also, create the matrix of exogenous variables for the pre-forecast period
    data_exo_a=[];
    for ii=1:numexo
        data_exo_a=[data_exo_a data(1:Fstartlocation-1,exolocation(ii,1))];
    end
    
    % create the matrix of endogenous variables for the period common to actual data and forecasts (for forecast evaluation)
    % first, check that there are such common periods: it is the case if the beginning of the forecast period is anterior to the end of the dataset
    if Fstartlocation<=dataendlocation
        % return a scalar value to indicate that forecast evaluation is possible
        Fcomp=1;
        % compute the number of common periods
        % if the forecast period ends before the end of the data set, the common periods end with the end of the forecasts
        if Fendlocation<=dataendlocation
            Fcperiods=Fperiods;
            % record the end date of the common periods
            Fcenddate=Fenddate;
            % if the forecast period ends later than the data set, the common periods end at the end of the data set
        elseif Fendlocation>dataendlocation
            Fcperiods=dataendlocation-Fstartlocation+1;
            % record the end date of the common periods
            Fcenddate=datestrings{end,1};
        end
        
        % create a matrix of endogenous data for the common periods
        data_endo_c=[];
        for ii=1:numendo
            data_endo_c=[data_endo_c data(Fstartlocation:min(dataendlocation,Fendlocation),endolocation(ii,1))];
        end
        
        % create a lagged matrix of endogenous data prior to the common periods
        % the number of values is equal to "lags"; this will be used for computation of the log predictive score
        data_endo_c_lags=[];
        for ii=1:numendo
            data_endo_c_lags=[data_endo_c_lags data(Fstartlocation-lags:Fstartlocation-1,endolocation(ii,1))];
        end
        
        % create a matrix of exogenous data for the common periods
        data_exo_c=[];
        for ii=1:numexo
            data_exo_c=[data_exo_c data(Fstartlocation:min(dataendlocation,Fendlocation),exolocation(ii,1))];
        end
        
        % create a lagged matrix of exogenous data prior to the common periods
        % the number of values is equal to "lags"; this will be used for computation of the log predictive score
        data_exo_c_lags=[];
        for ii=1:numexo
            data_exo_c_lags=[data_exo_c_lags data(Fstartlocation-lags:Fstartlocation-1,exolocation(ii,1))];
        end
        % if there are no common periods, return a scalar value to indicate that forecast evaluation is not possible
    else
        Fcomp=0;
        Fcperiods=0;
        data_exo_c=[];
        data_endo_c=[];
        Fcenddate=[];
        data_endo_c_lags=[];
        data_exo_c_lags=[];
    end
    
    
    
    % now create the matrix data_exo_p
    % two possible cases
    
    % if there are no exogenous variables, simply create an empty matrix
    if isempty(exo)
        data_exo_p=[];
        
        % if there are exogenous variables, load from excel
    else
        % load the data from Excel
        [num txt strngs]=xlsread(pref.excelFile,'pred exo');
        
        % obtain the row location of the forecast start date
        [Fstartlocation,~]=find(strcmp(strngs,Fstartdate));
        % check that the start date for the forecast appears in the sheet; if not, return an error
        if isempty(Fstartlocation)
            message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the start date for forecasts (' Fstartdate ') cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that dates are case-sensitive.'];
            msgbox(message);
            error('programme termination: data error');
        end
        % obtain the row location of the forecast end date
        [Fendlocation,~]=find(strcmp(strngs,Fenddate));
        % check that the end date for the forecast appears in the sheet; if not, return an error
        if isempty(Fendlocation)
            message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the end date for forecasts (' Fenddate ') cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that dates are case-sensitive.'];
            msgbox(message);
            error('programme termination: data error');
        end
        
        % identify the strings for the exogenous variables
        % loop over exogenous
        for ii=1:numexo
            % try to find a column match for exogenous variable ii
            [~,location]=find(strcmp(strngs,exo{ii,1}));
            % if no match is found, return an error
            if isempty(location)
                message=['Error: a forecast application is selected for a model that uses exogenous variables. Hence, predicted exogenous values should be supplied over the forecast periods. Yet the exogenous variable ''' exo{ii,1} ''' cannot be found on the ''pred exo'' sheet of the Excel data file. Please verify that this sheet is properly filled, and remember that variable names are case-sensitive.'];
                msgbox(message);
                error('programme termination: data error');
                % else, record the value
            else
                pexolocation(ii,1)=location;
            end
        end
        
        % if everything was fine, reconstitute the matrix data_exo_p
        % initiate
        data_exo_p=[];
        % loop over exogenous variables
        for ii=1:numexo
            % initiate the predicted values for exogenous variable ii
            predexo=[];
            % loop over forecast periods
            for jj=1:Fperiods
                temp=strngs{Fstartlocation+jj-1,pexolocation(ii,1)};
                % if this entry is empty or NaN, return an error
                if (isempty(temp) || (temp<=inf)==0)
                    message=['Error: the predicted value for exogenous variable ' exo{ii,1} ' at forecast period ' strngs{Fstartlocation+jj,1} ' (and possibly other entries) is either empty or NaN. Please verify that the ''pred exo'' sheet of the Excel data file is properly filled.'];
                    msgbox(message);
                    error('programme termination: data error');
                    % if this entry is a number, record it
                else
                    predexo=[predexo;temp];
                end
            end
            % concatenate
            data_exo_p=[data_exo_p predexo];
        end
        
        % also, record the exogenous values on Excel
        % replace NaN entries by blanks
        strngs(cellfun(@(x) any(isnan(x)),strngs))={[]};
        % then save on Excel
        if pref.results==1
            bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),strngs,'pred exo','A1');
        end
    end
    
    
    
    
end

end
