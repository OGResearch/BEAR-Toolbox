function [outUnconditionalDrawer, outIdentifierDrawer] = adapterDrawer(this, meta)
        
        %sizes 
        numEn = meta.NumEndogenousColumns;
        numARows = numEn * meta.Order;
        numBRows = numARows + meta.NumExogenousColumns;

        %IRF periods
        IRFperiods = meta.IRFperiods;

        %other settings
        EstimationSpan = this.EstimationSpan;

    function [drawStruct] = unconditionalDrawer(sampleStruct, forecastStart, forecastHorizon )
    
        startingIndex = numel(EstimationSpan) - datex.diff(EstimationSpan(end), forecastStart) - 1;

        %draw beta, omega and sigma and F from their posterior distributions
        
        % draw beta
        beta = sampleStruct.beta{startingIndex, 1};
        B = reshape(beta, numBRows, numEn); 
        Sigma = reshape(sampleStruct.sigma, numEn, numEn);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:forecastHorizon
           drawStruct.As{jj, 1}(:, :) = B(1:numARows, :);
           drawStruct.Cs{jj, 1}(:, :) = B(numARows + 1:end, :); 
           drawStruct.Sigmas{jj, 1}(:, :) = Sigma; 
        end
    end

    function [drawStruct] = identifierDrawer(sampleStruct)
    
        startingIndex = numel(EstimationSpan);

        %draw beta, omega from their posterior distribution  
        % draw beta
        beta = sampleStruct.beta{startingIndex, 1};
        B = reshape(beta, numBRows, numEn);                        
        drawStruct.As = cell(IRFperiods, 1);
        drawStruct.Cs = cell(IRFperiods, 1);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:IRFperiods    
               drawStruct.As{jj,1}(:, :) = B(1:numARows, :);
               drawStruct.Cs{jj,1}(:, :) = B(numARows + 1:end, :); 
        end
       
        drawStruct.Sigma = reshape(sampleStruct.sigma, numEn, numEn);   
    end

    outUnconditionalDrawer = @unconditionalDrawer;
    outIdentifierDrawer = @identifierDrawer;

end