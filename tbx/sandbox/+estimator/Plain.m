classdef Plain < estimator.Base

    methods

        function createDrawers(this, meta)
            %[
            numY = meta.NumEndogenousNames;
            numBRows = numY * meta.Order + meta.NumExogenousNames + double(meta.HasIntercept);            
            order = meta.Order;
            estimationHorizon = numel(meta.ShortSpan);
            %
            function draw = historyDrawer(sample)
                sample.B = reshape(sample.beta, numBRows, numY);
                A = sample.B(1:numY*order, :);
                C = sample.B(numY*order+1:end, :);
                draw = struct();
                draw.A = repmat({A}, estimationHorizon, 1);
                draw.C = repmat({C}, estimationHorizon, 1);
                draw.Sigma = repmat({sample.sigma}, estimationHorizon, 1);
            end%
            %
            function draw = unconditionalDrawer(sample, start, horizon)
                sample.B = reshape(sample.beta, numBRows, numY);
                A = sample.B(1:numY * order, :);
                C = sample.B(numY*order + 1:end, :);
                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                draw.Sigma = repmat({sample.sigma}, horizon, 1);
            end%
            %
            function draw = identificationDrawer(sample)
                sample.B = reshape(sample.beta, numBRows, numY);
                A = sample.B(1:numY*order, :);
                %
                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.Sigma = sample.sigma;
            end%
            %
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = [];
            this.IdentificationDrawer = []; %@identificationDrawer;
            %]
        end%

    end
end