function [outUnconditionalDrawer, outIdentifierDrawer] = adapterDrawer(this, meta)
        
        %sizes 
        numEn = meta.NumEndogenousColumns;
        numARows = numEn * meta.Order;
        numBRows = numARows + meta.NumExogenousColumns;
        sizeB = numEn * numBRows;

        %IRF periods
        IRFperiods = meta.IRFperiods;

        %other settings
        gamma = this.Settings.gamma;
        EstimationSpan = this.EstimationSpan;


    function [As, Cs, Sigmas] = unconditionalDrawer(sampleStruct, forecastStart, forecastHorizon )
    
        startingIndex = numel(EstimationSpan) - datex.diff(EstimationSpan(end), forecastStart) - 1;

        beta = sampleStruct.beta;
        % reshape it to obtain B
        B = reshape(beta, numBRows, numEn);

        % draw F from its posterior distribution
        F = sparse(sampleStruct.F(:,:));

        % step 4: draw phi and gamma from their posteriors
        phi = sampleStruct.phi';
        gamma = sampleStruct.gamma';
        lambda =  sampleStruct.L_gibbs{startingIndex,:}';

        As = cell(forecastHorizon, 1);
        Cs = cell(forecastHorizon, 1);
        Sigmas = cell(forecastHorizon, 1);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:forecastHorizon
            
            % update beta
            As{jj, 1}(:, :) = B(1:numARows, :);
            Cs{jj, 1}(:, :) = B(numARows + 1:end, :); 

            for kk = 1:numEn
                lambda(kk, 1)=gamma(kk, 1)*lambda(kk, 1) + phi(kk, 1)^0.5 * randn;
            end

            % obtain Lambda_t
            Lambda = sparse(diag(sbar .* exp(lambda)));
           
            % recover sigma_t and draw the residuals
            Sigmas{jj, 1}(:, :) = full(F * Lambda * F');
        end
    end

    function [As, Cs, Sigma] = identifierDrawer(sampleStruct)
    
        beta = sampleStruct.beta;
        % reshape it to obtain B
        B = reshape(beta, numBRows, numEn);
                        
        As = cell(IRFperiods, 1);
        Cs = cell(IRFperiods, 1);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:IRFperiods
               As{jj,1}(:, :) = B(1:numARows, :);
               Cs{jj,1}(:, :) = B(numARows + 1:end, :); 
        end
       
        Sigma = reshape(sampleStruct.sigma_avg, numEn, numEn);   
    end

    outUnconditionalDrawer = @unconditionalDrawer;
    outIdentifierDrawer = @identifierDrawer;

end