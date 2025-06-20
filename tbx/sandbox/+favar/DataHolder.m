classdef DataHolder < model.DataHolder

    properties
        Reducibles                          % Raw Z data
    end
    
    methods

        function this = DataHolder(meta, dataTable, varargin)
            arguments
                meta (1, 1) favar.Meta
                dataTable (:, :) timetable
            end
            arguments (Repeating)
                varargin
            end

            this = this@model.DataHolder(meta, dataTable, varargin{:});
            this.Reducibles = tablex.retrieveData(dataTable, meta.ReducibleNames, this.Span, varargin{:});
        end


        function YXZ = getYXZ(this, options)
            arguments
                this
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
                options.Standardized (1, 1) logical = true
            end

            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end

            % --- Get raw Y and X from superclass
            YXZ = getYXZ@model.DataHolder(this, span=options.Span, index=index);

            Z = this.getZ(span=options.Span, index=index);
                
            YXZ{3} = Z;
        end

        function Z = getZ(this, options)
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
           
            sourceZ = this.Reducibles;
            
            numIndex = numel(index);
            Z = nan(numIndex, size(this.Reducibles, 2), size(this.Reducibles, 3));

            % Only assign within valid time span
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Z(within, :, :) = sourceZ(indexWithin, :, :);
        end%

    end
end