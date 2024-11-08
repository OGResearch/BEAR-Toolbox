function [cforecast_record] = conditionalForecastPanel(meta, pref, fcastStart, fcastEnd, shortYXZ)

    numEndog = meta.NumEndogenousConcepts;
    numExog = meta.NumExogenousNames+double(meta.HasIntercept);
    numCountries = meta.NumUnits;
    numLags = meta.NumLags;
    const = meta.HasIntercept;
    numPresampled = meta.NumPresampled;
    % names stored in a column
    endo = meta.EndogenousConcepts';
    units = meta.Units';
    exo = meta.ExogenousNames';

    numBRows = numEndog*meta.Order + numExog;

    % Conditional forecast type. Hardcoded as 2 for now.
    % CFt = this.Settings.CFt;
    CFt = 2;
    % Panel model type. Here, we theoretically only need to distiguish if it is with cross-sections or not. I hard code it as 2 for NormalWishartPanel (no cross-sections).
    panel = 2;

    fcastSpan = datex.span(fcastStart, fcastEnd);
    Fperiods = length(fcastSpan);
    fStart = lower(datestr(fcastStart,'YYYYQQ'));
    fEnd = lower(datestr(fcastEnd,'YYYYQQ'));

    % We only need data that ends at fcastStart-1, so I call it shortY.
    [shortY, ~, ~] = shortYXZ{:};
    
    % Load conditional forecast conditions
    [cfcondsFull, cfshocksFull, cfblocksFull] = bear.loadcfpan(endo, units, panel, CFt, fStart, fEnd, Fperiods, pref);

    % load predicted exogenous data (I extracted the procedure here from the dirty house, but I removed all the consistency checks. Orriginally it will throw an error if some period in the forecast span is not populated in the excel file.)
    [~, ~, strngs] = xlsread(pref.excelFile, 'pan pred exo');
    % obtain the row location of the forecast start date
    [Fstartlocation,~] = find(strcmp(strngs,fStart));

    % loop over exogenous
    for ii=1:numExog
        % try to find a column match for exogenous variable ii
        [~,location]=find(strcmp(strngs,exo{ii,1}));
        pexolocation(ii,1)=location;
    end

    % if everything was fine, reconstitute the matrix data_exo_p (I call it here shortXp)
    % initiate
    shortXp = [];
    % loop over exogenous variables
    for ii=1:numExog

        % initiate the predicted values for exogenous variable ii
        predexo=[];
        % loop over forecast periods
        for jj=1:Fperiods

            temp = strngs{Fstartlocation+jj-1,pexolocation(ii,1)};
            predexo = [predexo;temp]; 

        end

        shortXp = [shortXp predexo];

    end

    % initiate the cell recording the Gibbs sampler draws
    cforecast_record = {};

    % loop over units
    for indCountry = 1:numCountries
        
        cfconds = cfcondsFull(:,:,indCountry);
        cfshocks = cfshocksFull(:,:,indCountry);
        cfblocks = cfblocksFull(:,:,indCountry);

        % check wether there are any conditions on unit ii
        nconds = numel(cfconds(cellfun(@(x) any(~isempty(x)),cfconds)));

        % if there are conditions
        if nconds~=0

            % run the Gibbs sampler for unit ii
            % cforecast_record(:,:,ii)=bear.cforecast(shortY(:,:,ii),shortX,data_exo_p,It,Bu,Fperiods,temp1,temp2,temp3,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
            if const==1

                shortXp = [ones(Fperiods,1) shortXp];
                % if no constant was included, do nothing

            end

            % loop over Gibbs samplers
            for indSample = 1:numPresampled

                beta = this.Presampled{indSample}.beta;
                D = this.Presampled{indSample}.D;
                D = reshape(D, numEndog, numEndog);

                % step 2: compute regular forecasts for the data (without shocks)
                fmat=bear.forecastsim(shortY(:,:,indCountry),shortXp,beta,numEndog,numLags,numBRows,Fperiods);

                % step 3: compute IRFs and orthogonalised IRFs matrices
                [~,ortirfmat]=bear.irfsim(beta,D,numEndog,numExog,numLags,numBRows,Fperiods);

                % step 4: compute the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
                if CFt==1

                    eta = bear.shocksim1(cfconds,Fperiods,numEndog,fmat,ortirfmat);

                elseif CFt==2

                    eta = bear.shocksim2_ogr(cfconds,cfshocks,cfblocks,Fperiods,numEndog,fmat,ortirfmat);

                end 

                eta = reshape(eta, numEndog, Fperiods);
                
                % step 5: obtain the conditional forecasts
                for indPeriod = 1:Fperiods
                    % compute shock contribution to forecast values
                    % create a temporary vector of cumulated shock contributions
                    temp = zeros(numEndog,1);

                    % loop over periods up the the one currently considered
                    for kk = 1:indPeriod

                        temp = temp + ortirfmat(:,:,indPeriod-kk+1)*eta(:,kk);

                    end

                    % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
                    cdforecast(indPeriod,:) = fmat(indPeriod,:) + temp';

                end
                clear temp

                % step 6: then obtain point estimates and credibility intervals
                % loop over variables
                for indVar = 1:numEndog
                    % record the conditional forecasts for variable indVar
                    cforecast_record{indVar,1}(indSample,:,indCountry) = cdforecast(:,indVar)';
                    % record the shocks (not used anywhere so I comment it out)
                    % strshocks_record{indVar,1}(indSample,:,indCountry) = eta(indVar,:)';
                end
                % then go for next iteration
            end

            % then obtain point estimates and credibility intervals (This can be produced outside of this function so I comment it out)
            % cforecast_estimates(:,:,indCountry) = bear.festimates(cforecast_record(:,:,indCountry),numEndog,Fperiods,Fband);

        % if there are no conditions, return empty elements
        elseif nconds==0
            cforecast_record(:,:,indCountry) = cell(numEndog,1);
            % cforecast_estimates(:,:,indCountry) = cell(numEndog,1);
        end
    end
end

