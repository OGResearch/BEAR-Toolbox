classdef PlainPanel < estimator.Base
    methods
        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numARows = numEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numBRows = numARows + numExog;
            estimationHorizon = numel(meta.ShortSpan);



            function drawStruct = drawer(sampleStruct, horizon)

                beta = sampleStruct.beta;
                sigma = sampleStruct.sigma;

                % initialization
                A = nan(numARows, numEndog, numCountries);
                C = nan(numExog, numEndog, numCountries);

                Sigma = nan(numEndog, numEndog, numCountries);

                % iterate over countries
                for ii = 1:numCountries

                    B_temp = reshape(...
                        beta(:, ii),...
                        numBRows,...
                        numEndog...
                        );

                    sigma_temp = reshape(...
                        sigma(:, ii),...
                        numEndog,...
                        numEndog...
                        );

                    % Pack in blocks
                    A_temp = B_temp(1:numARows,:);

                    C_temp = B_temp(numARows+1:end,:);

                    % Pack in blocks
                    A(:,:, ii) = A_temp;

                    C(:,:, ii) = C_temp;

                    Sigma(:,:, ii) = sigma_temp;

                end

                drawStruct = struct();
                drawStruct.A = repmat({A}, horizon, 1);
                drawStruct.C = repmat({C}, horizon, 1);
                drawStruct.Sigma = Sigma;

            end

            function draw = unconditionalDrawer(sampleStruct, start, forecastHorizon)
                draw = drawer(sampleStruct, forecastHorizon);
                draw.Sigma = repmat({draw.Sigma}, forecastHorizon, 1);
            end%

            function draw = historyDrawer(sampleStruct)
                draw = drawer(sampleStruct, estimationHorizon);
                draw.Sigma = repmat({draw.Sigma}, estimationHorizon, 1);
            end%

            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.IdentificationDrawer = @drawer;
            %]
        end%
    end
end