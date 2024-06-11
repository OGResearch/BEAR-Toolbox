function [data,data_endo, data_endo_a,data_endo_c,data_endo_c_lags,favar, data_endo_orig]=...
    gensample_favar(opts,favar, names)

pref = struct('excelFile', opts.excelFile, ...
    'results_path', opts.results_path, ...
    'results_sub', opts.results_sub, ...
    'results', opts.results, ...
    'plot', opts.plot, ...
    'workspace', opts.workspace);


VARtype = opts.VARtype;
startdate = bear.utils.fixstring(opts.startdate);
enddate   = bear.utils.fixstring(opts.enddate);

Fenddate   = bear.utils.fixstring(opts.Fenddate);
[endo, ~] = nw_favar.endo_exo(opts);
favar = nw_favar.initfavar(favar);

endo = endo(contains(endo,'factor'));
numendo = numel(endo);

lags = opts.lags;
F = opts.F;
CF = opts.CF;

IRFt = opts.IRFt;

% identify the date strings
datestrings=names(2:end,1);
% identify the position of the string corresponding to the start period
startlocationData=find(strcmp(datestrings,startdate));
% identify the position of the string corresponding to the end period


[informationstartlocation,~,favar]=bear.favar_gensample1(startdate,enddate,favar,pref);

data =[];

if favar.transformation==1
        startlocation=informationstartlocation;
        % check is correct
else
        startlocation=startlocationData;
end


[data,variablestrings,favar]=bear.favar_gensample2(data,endo,"",startlocation,lags,favar);



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


% Phase 2: creation of the data matrices data_endo and data_exo

% now create the matrix of endogenous variables for the estimation sample
% it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
data_endo=[];
% loop over endogenous variables
for ii=1:numendo
    data_endo=[data_endo data(:,endolocation(ii,1))];
end

%% FAVAR

if favar.transformation==1
    % correct order of transformationindex_endo
    favar.transformationindex_endo=[];
    for ii=1:size(endo,1)
        favar.transformationindex_endo=[favar.transformationindex_endo favar.transformationindex_endo_temp(:,endolocation(ii,1))];
    end
end
% correct order of stddev
favar.data_exfactors_stddev=[];
for ii=1:size(endo,1)
    favar.data_exfactors_stddev=[favar.data_exfactors_stddev favar.data_exfactors_stddev_temp(:,endolocation(ii,1))];
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
data_endo_orig = data_endo;
[data_endo,~]=bear.favar_gensample3(data_endo_orig,favar);
    
    
       
%%%% stationarity test
% endostrings=endo(favar.variablestrings_exfactors,1);
% allstrings=[favar.informationvariablestrings,endostrings'];
% NSTindex=[];
% NST2index=[];
% catallstrings=[];
% catallstrings2=[];
% count=0;
% count2=0;
% for ii=1:size(favar.XY,2)
%     adf(ii,1)=adftest(favar.XY(:,ii));
%     kpss(ii,1)=kpsstest(favar.XY(:,ii));
%     if adf(ii,1)==0 %|| kpss(ii,1)==1
%         count=count+1;
%         NSTallstrings{count,1}=allstrings(1,ii);
%         NSTindex=[NSTindex;ii];
%         catallstrings=strcat(catallstrings,', ',NSTallstrings{count,1});
%     end
%     if kpss(ii,1)==1
%         count2=count2+1;
%         NST2allstrings{count2,1}=allstrings(1,ii);
%         NST2index=[NST2index;ii];
%         catallstrings2=strcat(catallstrings2,', ',NST2allstrings{count2,1});
%     end
% end
% if size(NSTindex,1) > 0
% fprintf('%d%s%s%s\n',size(NSTindex,1),' series in X are not stationary (ADF test): ',catallstrings{1,1},'.');
% end
% if size(NST2index,1) > 0
% fprintf('%d%s%s%s\n',size(NST2index,1),' series in X are not stationary (KPSS test): ',catallstrings2{1,1},'.');
% end
%%%%
    
    



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


% Phase 3: determination of the position of the forecast start and end periods

% if both unconditional and conditional forecasts were not selected, there is no need for all the forecast-specific matrices: simply return empty matrices
if (VARtype==1 && F==0) || ((VARtype==2 || VARtype==3 || VARtype==5 || VARtype==6 ) && (F==0 && CF==0))
    data_endo_a=[];
    data_endo_c=[];
    data_endo_c_lags=[];
    
    % if forecast were selected, create all the required elements
else
    datestrings=names(2:end,1);
    % identify the location of the last period in the dataset
    dataendlocation=size(datestrings,1);

    [Fstartlocation,Fperiods] = nw_favar.get_fcast_rng(datestrings,opts);
    Fendlocation = Fstartlocation + Fperiods -1;
    % now create the matrix of endogenous variables for the pre-forecast period
    % it is simply the concatenation of the vectors of each endogenous variables, over the selected sample dates
    data_endo_a=[];
    % loop over endogenous variables
    for ii=1:numendo
        data_endo_a=[data_endo_a data(1:Fstartlocation-1,endolocation(ii,1))];
    end
    
    % create the matrix of endogenous variables for the period common to actual data and forecasts (for forecast evaluation)
    % first, check that there are such common periods: it is the case if the beginning of the forecast period is anterior to the end of the dataset
    if Fstartlocation<=dataendlocation
        % return a scalar value to indicate that forecast evaluation is possible
        % compute the number of common periods
        % if the forecast period ends before the end of the data set, the common periods end with the end of the forecasts
        
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
        

        % if there are no common periods, return a scalar value to indicate that forecast evaluation is not possible
    else
        data_endo_c=[];
        data_endo_c_lags=[];
    end    
end

end