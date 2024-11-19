
classdef (Abstract) PlainDrawersMixin < handle

    methods
        function createDrawers(this, meta)
            arguments
                this
                meta (1, 1) model.Meta
            end
            %[
            %
            numY = meta.NumEndogenousNames;
            % numBRows = numY * meta.Order + meta.NumExogenousNames + double(meta.HasIntercept);
            order = meta.Order;
            numL = numY * order;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            %
            function draw = drawer(sample, horizon)
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.A = wrap(A);
                draw.C = wrap(C);
                draw.Sigma = wrap(sample.sigma);
            end%
            %
            function draw = conditionaldrawer(sample, horizon)
                beta = sample.beta;
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.beta = wrap(beta);
            end%
            %
            function draw = identificationDrawer(sample)
                horizon = identificationHorizon;
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.A = wrap(A);
                draw.C = wrap(C);
                draw.Sigma = sample.sigma;
            end%
            %
            this.HistoryDrawer = @(sample) drawer(sample, estimationHorizon);
            this.UnconditionalDrawer = @(sample, start, horizon) drawer(sample, horizon);
            this.ConditionalDrawer = @(sample, start, horizon) conditionaldrawer(sample, horizon);
            this.IdentificationDrawer = @identificationDrawer;
            %
            %]
        end%
    end

end

