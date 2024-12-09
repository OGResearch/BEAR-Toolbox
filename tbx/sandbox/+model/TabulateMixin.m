
classdef TabulateMixin < handle

    methods
        function outTbx = tabulateAcrossSamples(this, calculate4S, span, variantDim, initFunc, dimNames, options)
            % Tabulate a 3D system property
            arguments
                this
                calculate4S function_handle
                span (1, :) datetime
                variantDim (1, 1) double
                initFunc function_handle
                dimNames (1, :) cell
                options.IncludeInitial (1, 1) logical
            end
            %
            meta = this.Meta;
            order = meta.Order;
            numV = this.NumPresampled;
            %
            % Y = nan(numT, numY, numE, numV);
            cellY = cell(1, numV);
            for i = 1 : numV
                sample = this.Presampled{i};
                [Y4S, sample] = calculate4S(sample);
                cellY{i} = Y4S;
                this.Presampled{i} = sample;
            end
            Y = cat(variantDim, cellY{:});
            %
            numT = size(Y, 1);
            startPeriod = span(1);
            endPeriod = span(end);
            span = datex.span(startPeriod, endPeriod);
            if options.IncludeInitial
                initSize = [order, size(Y, 2), size(Y, 3), size(Y, 4)];
                initY = initFunc(initSize);
                Y = [initY; Y];
                span = datex.longSpanFromShortSpan(span, order);
            end
            %
            outNames = dimNames{1};
            outTbx = tablex.fromNumericArray(Y, outNames, span, variantDim=variantDim);
            outTbx = tablex.setHigherDims(outTbx, dimNames{2:end});
            %]
        end%
    end

end

