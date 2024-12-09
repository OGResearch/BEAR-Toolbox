
classdef Cholesky < identifier.Base

    properties
        Order (1, :) string
    end

    methods
        function this = Cholesky(options)
            arguments
                options.Order (1, :) string = string.empty(1, 0)
            end
            if numel(options.Order) ~= numel(unique(options.Order))
                error("Duplicate names found in the Cholesky order.");
            end
            this.Order = options.Order;
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            meta = modelS.Meta;
            horizon = modelS.Meta.IdentificationHorizon;
            samplerR = modelS.ReducedForm.Estimator.Sampler;
            drawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            %
            [order, backOrder] = this.resolveOrder(meta);
            if isempty(order)
                candidator = @chol;
            else
                reorder = @(Sigma) chol(Sigma(order, order));
                backorder = @(P) P(:, backOrder);
                candidator = @(Sigma) backorder(reorder(Sigma));
            end
            %
            function sample = samplerS()
                this.SampleCounter = this.SampleCounter + 1;
                sample = samplerR();
                draw = drawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                sample.IdentificationDraw = draw;
                Sigma = (draw.Sigma + draw.Sigma')/2;
                sample.D = candidator(Sigma);
                this.CandidateCounter = this.CandidateCounter + 1;
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%

        function [order, backOrder] = resolveOrder(this, meta)
            customOrder = this.Order;
            if isempty(customOrder)
                order = [];
                backOrder = [];
                return
            end
            endogenousNames = meta.EndogenousNames;
            dict = textual.createDictionary(endogenousNames);
            endogenousNamesReordered = [customOrder, setdiff(endogenousNames, customOrder, "stable")];
            order = [];
            for n = endogenousNamesReordered
                order(end+1) = dict.(n);
            end
            [~, backOrder] = sort(order);
        end%
    end

end

