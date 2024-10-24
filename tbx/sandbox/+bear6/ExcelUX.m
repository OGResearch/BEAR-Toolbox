
classdef ExcelUX < handle

    properties (Constant)
        DATA_SOURCE_SHEET_NAME = "Data Source"
        META_SHEET_NAME = "Meta Information"
        CELL_READER_OPTIONS = {"Range", [1, 1], "TextType", "string", }
    end


    properties
        FilePath (1, 1) string
        DataSource (:, :) cell
        Meta (:, :) cell

        Config (1, 1) bear6.Config
    end


    methods

        function this = ExcelUX(options)
            arguments
                options.FilePath (1, 1) string = "BEAR6-EstimationUX.xlsx"
            end
            this.FilePath = options.FilePath;
            this.readAll();
            this.configureAll();
        end%


        function readAll(this)
            this.readDataSource();
            this.readMeta();
        end%


        function readDataSource(this)
            this.DataSource = readcell( ...
                this.FilePath ...
                , "sheet", this.DATA_SOURCE_SHEET_NAME ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readMeta(this)
            this.Meta = readcell( ...
                this.FilePath ...
                , "sheet", this.META_SHEET_NAME ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function configureAll(this)
            this.configureDataSource();
            this.configureReducedFormMeta();
        end%


        function configureDataSource(this)
            this.Config.DataSource_Format = this.DataSource{2, 2};
            this.Config.DataSource_FilePath = this.DataSource{3, 2};
        end%


        function configureReducedFormMeta(this)
            this.Config.ReducedFormMeta_Units = stringListFromCellArray(this.Meta(2, 2:end), whenEmpty="");
            this.Config.ReducedFormMeta_EndogenousConcepts = stringListFromCellArray(this.Meta(3, 2:end));
            this.Config.ReducedFormMeta_ExogenousNames = stringListFromCellArray(this.Meta(4, 2:end));
            this.Config.ReducedFormMeta_HasIntercept = this.Meta{5, 2};
            this.Config.ReducedFormMeta_Order = this.Meta{6, 2};
            this.Config.ReducedFormMeta_EstimationStart = this.Meta{7, 2};
            this.Config.ReducedFormMeta_EstimationEnd = this.Meta{8, 2};
        end%

    end

end


function output = stringListFromCellArray(input, options)
    arguments
        input (1, :) cell
        options.WhenEmpty (1, :) string = string.empty(1, 0)
    end
    isMissing = @(x) isempty(x) || ismissing(x) || (isstring(x) && strlength(x) == 0);
    indexMissing = cellfun(isMissing, input);
    input(indexMissing) = [];
    output = string(input);
    if isempty(output)
        output = options.WhenEmpty;
    end
end%


