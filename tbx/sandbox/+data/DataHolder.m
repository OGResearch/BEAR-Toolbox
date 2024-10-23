
classdef DataHolder < handle

    properties
        Span
        Endogenous
        Exogenous
        Reducibles
    end


    methods

        function this = DataHolder(meta, estimator, inputTable, varargin)
            arguments
                meta (1, 1) meta.ReducedForm
                estimator (1, 1) estimator.Base
                inputTable (:, :) timetable
            end
            arguments (Repeating)
                varargin
            end
            this.Span = tablex.span(inputTable);
            this.Endogenous = tablex.retrieveData(inputTable, meta.EndogenousNames, this.Span, varargin{:});
            this.Exogenous = tablex.retrieveData(inputTable, meta.ExogenousNames, this.Span, varargin{:});
            this.Reducibles = tablex.retrieveData(inputTable, meta.ReducibleNames, this.Span, varargin{:});
            estimator.reorganizeDataHolderWithMultipleUnits(this, meta);
        end%


        function index = getSpanIndex(this, span)
            arguments
                this
                span (1, :) datetime
            end
            if isempty(span)
                index = zeros(0, 1);
                return
            end
            startPeriod = span(1);
            endPeriod = span(end);
            startIndex = datex.diff(startPeriod, this.Span(1)) + 1;
            endIndex = datex.diff(endPeriod, this.Span(1)) + 1;
            if startIndex < 1 || startIndex > numel(this.Span)
                error("Start period out of range");
            end
            index = transpose(startIndex : endIndex);
        end%


        function YXZ = getYXZ(this, options)
            arguments
                this
                %
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
            end
            %
            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end
            %
            numIndex = numel(index);
            Y = nan(numIndex, size(this.Endogenous, 2));
            X = nan(numIndex, size(this.Exogenous, 2));
            Z = nan(numIndex, size(this.Reducibles, 2));
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Y(within, :) = this.Endogenous(indexWithin, :);
            X(within, :) = this.Exogenous(indexWithin, :);
            Z(within, :) = this.Reducibles(indexWithin, :);
            YXZ = {Y, X, Z};
        end%

    end

end

