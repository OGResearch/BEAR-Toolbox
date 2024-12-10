
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
            identificationDrawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
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
            %
            function sample = structuralSampler()
                this.SampleCounter = this.SampleCounter + 1;
                sample = samplerR();
                draw = identificationDrawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                sample.IdentificationDraw = draw;
                numUnits = size(draw.Sigma, 3);
                D = cell(1, numUnits);
                % Make sure we do not repeat the Cholesky decomposition for the
                % same Sigma matrix
                prevSigma = [];
                prevD = [];
                for i = 1 : numUnits
                    Sigma = draw.Sigma(:, :, i);
                    if isequal(Sigma, prevSigma)
                        D{i} = prevD;
                    else
                        symmetricSigma = (Sigma + Sigma')/2;
                        D{i} = candidator(symmetricSigma);
                        prevSigma = Sigma;
                        prevD = D{i};
                    end
                end
                sample.D = cat(3, D{:});
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

