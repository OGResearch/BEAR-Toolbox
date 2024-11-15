
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


            % TODO: Split into betaDrawer and sigmaDrawer
            function drawStruct = drawer(sampleStruct, horizon)

                beta = sampleStruct.beta;
                sigma = sampleStruct.sigma;

                % initialization
                A = nan(numARows, numEndog, numCountries);
                C = nan(numExog, numEndog, numCountries);

                Sigma = nan(numEndog, numEndog, numCountries);

                % iterate over countries
                for ii = 1 : numCountries

                    tempB = reshape( ...
                        beta(:, ii), ...
                        numBRows, ...
                        numEndog ...
                    );

                    tempSigma = reshape( ...
                        sigma(:, ii), ...
                        numEndog, ...
                        numEndog ...
                    );

                    % Pack in blocks
                    tempA = tempB(1:numARows,:);

                    tempC = tempB(numARows+1:end,:);

                    % Pack in blocks
                    A(:,:, ii) = tempA;

                    C(:,:, ii) = tempC;

                    Sigma(:,:, ii) = tempSigma;

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

            function draw = conditionalDrawer(sample)
                draw = struct();
                % TODO: implement
            end%

            this.IdentificationDrawer = @(sample) drawer(sample, identificationHorizon);
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%

    end

end

