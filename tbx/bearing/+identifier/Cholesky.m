
classdef Cholesky ...
    < identifier.Base ...
    & identifier.InstantMixin

    properties
        Order (1, :) string
        OrderIndex (1, :) double
        BackorderIndex (1, :) double
    end


    properties (Dependent)
        HasReordering
    end


    methods
        function beforeInitializeSampler(this, modelS)
            arguments
                this
                modelS (1, 1) model.Structural
            end
            meta = modelS.Meta;
            this.resolveOrder(meta);
        end%

        function this = Cholesky(options)
            arguments
                options.Order (1, :) string = string.empty(1, 0)
            end
            if numel(options.Order) ~= numel(unique(options.Order))
                error("Duplicate names found in the Cholesky order.");
            end
            this.Order = options.Order;
        end%

        function choleskator = getCholeskator(this)
            function P = choleskatorNoReordering(Sigma)
                P = chol(Sigma);
            end%
            %
            orderIndex = this.OrderIndex;
            backorderIndex = this.BackorderIndex;
            function P = choleskatorWithReordering(Sigma)
                P = chol(Sigma(orderIndex, orderIndex));
                P = P(:, backorderIndex);
            end%
            %
            if this.HasReordering
                choleskator = @choleskatorWithReordering;
            else
                choleskator = @choleskatorNoReordering;
            end
        end%

        function candidator = getCandidator(this)
            candidator = @(P) P;
        end%

        function resolveOrder(this, meta)
            this.OrderIndex = double.empty(1, 0);
            this.BackorderIndex = double.empty(1, 0);
            if isempty(this.Order)
                return
            end
            endogenousNames = meta.getSeparableEndogenousNames();
            dict = textual.createDictionary(endogenousNames);
            endogenousNamesReordered = [this.Order, setdiff(endogenousNames, this.Order, "stable")];
            order = [];
            for n = endogenousNamesReordered
                order(end+1) = dict.(n);
            end
            [~, backOrder] = sort(order);
            this.OrderIndex = order;
            this.BackorderIndex = backOrder;
        end%

        function out = get.HasReordering(this)
            out = ~isempty(this.Order);
        end%
    end

end

