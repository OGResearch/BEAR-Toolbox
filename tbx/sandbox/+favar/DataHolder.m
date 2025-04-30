
classdef DataHolder < model.DataHolder

    properties
        Reducibles
        StandardizedReducibles
        MeanStdReducibles
    end


    methods

        function this = DataHolder(meta, dataTable, varargin)
            arguments
                meta (1, 1) model.Meta
                dataTable (:, :) timetable
            end
            arguments (Repeating)
                varargin
            end
            this = this@model.DataHolder(meta, dataTable, varargin{:});
            this.Reducibles = tablex.retrieveData(dataTable, meta.ReducibleNames, this.Span, varargin{:});
            this.standardizeReducibles(meta);
        end%


        function standardizeReducibles(this, meta)
            Z = this.getZ(span=meta.LongSpan);
            [this.StandardizedReducibles, this.MeanStdReducibles] = transform.standardize(Z);
        end%


        function YXZ = getYXZ(this, options)
            arguments
                this
                %
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
                options.Standardized (1, 1) logical = true
            end
            %
            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end
            %
            YXZ = getYXZ@model.DataHolder(this, span=options.Span, index=options.Index);
            Z = this.getZ(span=options.Span, index=options.Index, standardized=options.Standardized);
            YXZ{3} = Z;
        end%


        function Z = getZ(this, options)
            arguments
                this
                %
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
                options.Standardized (1, 1) logical = true
            end
            %
            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end
            %
            if options.Standardized
                sourceZ = this.StandardizedReducibles;
            else
                sourceZ = this.Reducibles;
            end
            %
            numIndex = numel(index);
            Z = nan(numIndex, size(this.Reducibles, 2), size(this.Reducibles, 3));
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Z(within, :, :) = sourceZ(indexWithin, :, :);
            YXZ{3} = Z;
        end%

    end

end

