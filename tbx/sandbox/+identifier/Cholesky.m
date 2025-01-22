
classdef Cholesky < identifier.Base

    properties
        Order (1, :) string
        OrderIndex (1, :) double
        BackorderIndex (1, :) double
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

        function getCholeskator(this)
            function P = choleskatorNoReordering(Sigma)
                P = chol(Sigma);
            end%
            %
            function P = choleskatorWithReordering(Sigma)
                P = chol(Sigma(order, order));
                P = P(:, backOrder);
            end%
            choleskator = @chol;
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            meta = modelS.Meta;
            estimator = modelS.ReducedForm.Estimator;
            samplerR = estimator.Sampler;
            numUnits = meta.NumUnits;
            hasCrossUnitVariationInSigma = estimator.HasCrossUnitVariationInSigma;
            identificationDrawer = estimator.IdentificationDrawer;
            horizon = modelS.Meta.IdentificationHorizon;
            %
            [order, backOrder] = this.resolveOrder(meta);
            %
            % if isempty(order)
            %     candidator = @(Sigma) chol(identifier.makeSymmetric(Sigma));
            % else
            %     reorder = @(Sigma) chol(Sigma(order, order));
            %     backorder = @(P) P(:, backOrder);
            %     candidator = @(Sigma) backorder(reorder(identifier.makeSymmetric(Sigma));
            % end
            if isempty(order)
                choleskator = @choleskatorNoReordering;
            else
                choleskator = @choleskatorWithReordering;
            end
            candidator = @(X) X;
            %
            %
            function sample = structuralSampler()
                this.SampleCounter = this.SampleCounter + 1;
                sample = samplerR();
                draw = identificationDrawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                sample.IdentificationDraw = draw;
                % TODO: Refactor and get rid of an if statement
                if hasCrossUnitVariationInSigma
                    D = cell(1, numUnits);
                    for i = 1 : numUnits
                        Sigma = identifier.makeSymmetric(draw.Sigma(:, :, i));
                        P = choleskator(Sigma);
                        D{i} = candidator(P);
                        end
                    end
                    D = cat(3, D{:});
                else
                    Sigma = identifier.makeSymmetric(draw.Sigma(:, :, 1));
                    P = choleskator(Sigma);
                    D = candidator(P);
                    D = repmat(D, 1, 1, numUnits);
                end
                sample.D = D;
                this.CandidateCounter = this.CandidateCounter + 1;
            end%
            %
            %
            this.Sampler = @structuralSampler;
            %]
        end%

        function [order, backOrder] = resolveOrder(this, meta)
            %[
            customOrder = this.Order;
            if isempty(customOrder)
                order = [];
                backOrder = [];
                return
            end
            endogenousNames = meta.SeparableEndogenousNames;
            dict = textual.createDictionary(endogenousNames);
            endogenousNamesReordered = [customOrder, setdiff(endogenousNames, customOrder, "stable")];
            order = [];
            for n = endogenousNamesReordered
                order(end+1) = dict.(n);
            end
            [~, backOrder] = sort(order);
            %]
        end%
    end

end

