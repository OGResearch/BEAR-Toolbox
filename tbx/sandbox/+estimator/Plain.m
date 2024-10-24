classdef Plain < estimator.Base

    methods

        function createDrawers(this, meta)
            %[
            numY = meta.NumEndogenousNames;
            % numBRows = numY * meta.Order + meta.NumExogenousNames + double(meta.HasIntercept);
            order = meta.Order;
            numL = numY * order;
            estimationHorizon = numel(meta.ShortSpan);
            %
            function draw = drawer(sample, horizon)
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                draw = struct();
                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                draw.Sigma = sample.sigma; %repmat({sample.sigma}, horizon, 1);
            end%
            %
            function draw = historyDrawer(sample)
                draw = drawer(sample, estimationHorizon);
                draw.Sigma = repmat({sample.sigma}, estimationHorizon, 1);
            end%
            %
            function draw = unconditionalDrawer(sample, start, horizon)
                draw = drawer(sample, horizon);
                draw.Sigma = repmat({sample.sigma}, horizon, 1);
            end%
            %
            function draw = conditionalDrawer(sample, start, horizon)
                draw = drawer(sample, horizon);
                draw.Sigma = repmat({sample.sigma}, horizon, 1);
            end%
            %
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            this.IdentificationDrawer = @drawer;
            %]
        end%

    end
end
