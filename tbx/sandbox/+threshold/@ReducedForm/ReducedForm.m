
classdef ReducedForm < model.ReducedForm

    methods

        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longYXZ, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYXZ
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            meta = this.Meta;
            match = meta.EndogenousNames == meta.ThresholdVarName;
            thresholdIndex = find(match);
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);

            shortU1 = system.generateResiduals( ...
                draw.Sigma1 ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            shortU2 = system.generateResiduals( ...
                draw.Sigma2 ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            %
            % Run forecast
            %
            [shortY, shortU, initY, shortX] = system.forecastTH( ...
                draw.A1, draw.A2, draw.C1, draw.C2, longYXZ, shortU1, shortU2 ...
                , delay = draw.delay ...
                , threshold = draw.threshold ...
                , thresholdIndex = thresholdIndex ...
                , hasIntercept = options.HasIntercept ...
                , order=options.Order ...
            );
            shortY = cat(2, shortY);
            shortU = cat(2, shortU);
            initY = cat(2, initY);
        end%

    end



end

