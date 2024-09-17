function [data_endo, favar]=...
    gensample_favar(opts, data1, favar, startlocation)

[endo, ~] = nw_favar.endo_exo(opts);
flag_factor = contains(endo,'factor');
variablestrings = endo(~flag_factor);
numendo = numel(endo);
lags = opts.lags;

[data,variablestrings,favar]=bear.favar_gensample2(data1,endo,variablestrings,startlocation,lags,favar);

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
    [data_endo,favar]=bear.favar_gensample3(data_endo,favar);
end
