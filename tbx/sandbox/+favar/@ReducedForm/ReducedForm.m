
classdef ReducedForm < model.ReducedForm

    methods

        function [forecaster, tabulator] = prepareForecaster(this, shortFcastSpan, options)
            arguments
                this
                shortFcastSpan (1, :) datetime
                options.StochasticResiduals
                options.IncludeInitial
            end

            meta = this.Meta;
            fcastStart = shortFcastSpan(1);
            fcastEnd = shortFcastSpan(end);
            this.checkForecastSpan(fcastStart, fcastEnd);
            forecastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortFcastSpan);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            longYXZ = this.getSomeYXZ(longFcastSpan);
            [~, longX, ~] = longYXZ{:};
            outNames = [meta.FactorNames meta.EndogenousNames meta.ResidualNames, meta.ExogenousNames];
            numX = meta.NumExogenousNames;
            order = meta.Order;
            %
            function [shortY, shortU, initY, shortX, draw] = forecaster__(sample)
                [shortY, shortU, initY, shortX, draw] = this.forecast4S( ...
                    sample, longX, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end%
            %
            function outTable = tabulator__(shortY, shortU, initY, shortX)
                numPresampled = numel(shortY);
                shortY = cat(3, shortY{:});
                shortU = cat(3, shortU{:});
                shortX = cat(3, shortX{:});
                if options.IncludeInitial
                    outSpan = longFcastSpan;
                    initY = cat(3, initY{:});
                    initU = nan(size(initY));
                    initX = nan([order, numX, numPresampled]);
                    outData = [[initY, initU, initX]; [shortY, shortU, shortX]];
                else
                    outSpan = shortFcastSpan;
                    outData = [shortY, shortU, shortX];
                end
                %
                outTable = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=3);
            end%
            %
            forecaster = @forecaster__;
            tabulator = @tabulator__;
        end%

        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longX, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longX
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                %
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            %
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);

            shortU = system.generateResiduals( ...
                draw.Sigma ...
                , stochasticResiduals=options.StochasticResiduals ...
            );
            %
            % Run unit-specific forecast
            %
            [shortY, initY, shortX] = system.forecastFAVAR( ...
                draw.A, draw.C, sample.FY, longX, shortU ...
                , hasIntercept=options.HasIntercept ...
                , order=options.Order ...
            );

        end%

    end


    methods


        function [u, sample] = estimateResiduals4S(this, sample, longYXZ)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            [~, longX, ~] = longYXZ{:};
            u = system.calculateResidualsFAVAR( ...
                    draw.A, draw.C, sample.FY, longX ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
        end
        


    end

end

