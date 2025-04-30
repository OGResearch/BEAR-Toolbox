
classdef DataHolder < model.DataHolder

    properties
        Reducibles
        ReduciblesStandardized
        ReduciblesMeanStd
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
            this = this@model.DataHolder();
            this.Reducibles = tablex.retrieveData(dataTable, meta.ReducibleNames, this.Span, varargin{:});
            this.ReduciblesStandardized, this.ReduciblesMeanStd = transform.standardize(this.Reducibles);
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
            YXZ = getYXZ@model.DataHolder(this, options);
            numIndex = numel(index);
            Z = nan(numIndex, size(this.Reducibles, 2), size(this.Reducibles, 3));
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Z(within, :, :) = this.Reducibles(indexWithin, :, :);
            YXZ{3} = Z;
        end%

    end

end

