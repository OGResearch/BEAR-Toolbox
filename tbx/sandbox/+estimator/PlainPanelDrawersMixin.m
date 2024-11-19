
classdef (Abstract) PlainPanelDrawersMixin < handle

    methods

        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numARows = numEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numBRows = numARows + numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;


            function drawStruct = betaDrawer(sampleStruct, horizon)

                beta = sampleStruct.beta;

                % initialization
                A = nan(numARows, numEndog, numCountries);
                C = nan(numExog, numEndog, numCountries);

                % iterate over countries
                for ii = 1 : numCountries

                    tempB = reshape( ...
                        beta(:, ii), ...
                        numBRows, ...
                        numEndog ...
                    );

                    % Pack in blocks
                    tempA = tempB(1:numARows,:);

                    tempC = tempB(numARows+1:end,:);

                    % Pack in blocks
                    A(:,:, ii) = tempA;

                    C(:,:, ii) = tempC;

                end

                drawStruct = struct();
                drawStruct.A = repmat({A}, horizon, 1);
                drawStruct.C = repmat({C}, horizon, 1);

            end

            function drawStruct = sigmaDrawer(sampleStruct, horizon)

                sigma = sampleStruct.sigma;

                % initialization
                Sigma = nan(numEndog, numEndog, numCountries);

                % iterate over countries
                for ii = 1 : numCountries

                    tempSigma = reshape( ...
                        sigma(:, ii), ...
                        numEndog, ...
                        numEndog ...
                    );

                    Sigma(:,:, ii) = tempSigma;

                end

                drawStruct = struct();
                drawStruct.Sigma = Sigma;

            end

            function draw = unconditionalDrawer(sampleStruct, start, forecastHorizon)

                draw = betaDrawer(sampleStruct, forecastHorizon);
                drawS = sigmaDrawer(sampleStruct, forecastHorizon);
                draw.Sigma = repmat({drawS.Sigma}, forecastHorizon, 1);

            end%

            function draw = historyDrawer(sampleStruct)

                draw = betaDrawer(sampleStruct, estimationHorizon);
                drawS = sigmaDrawer(sampleStruct, estimationHorizon);
                draw.Sigma = repmat({drawS.Sigma}, estimationHorizon, 1);

            end%

            function draw = conditionalDrawer(sampleStruct, startingIndex, forecastHorizon)

                beta = sampleStruct.beta;
                draw.beta = repmat({beta}, forecastHorizon, 1);

            end%

            this.IdentificationDrawer = @(sample) drawer(sample, identificationHorizon);
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%

    end

end

