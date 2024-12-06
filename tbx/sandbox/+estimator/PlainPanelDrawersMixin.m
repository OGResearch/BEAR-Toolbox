
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


            function draw = betaDrawer(sample, horizon)

                beta = sample.beta;

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

                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);

            end

            function draw = sigmaDrawer(sample, horizon)

                sigma = sample.sigma;

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

                draw = struct();
                draw.Sigma = Sigma;

            end

            function draw = unconditionalDrawer(sample, start, forecastHorizon)

                draw = betaDrawer(sample, forecastHorizon);
                drawS = sigmaDrawer(sample, forecastHorizon);
                draw.Sigma = repmat({drawS.Sigma}, forecastHorizon, 1);

            end%

            function draw = drawer(sample, horizon)

                draw = betaDrawer(sample, horizon);
                drawS = sigmaDrawer(sample, horizon);
                draw.Sigma = drawS.Sigma;

            end%

            function draw = historyDrawer(sample)

                draw = betaDrawer(sample, estimationHorizon);
                drawS = sigmaDrawer(sample, estimationHorizon);
                draw.Sigma = repmat({drawS.Sigma}, estimationHorizon, 1);

            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon)

                beta = sample.beta;
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

