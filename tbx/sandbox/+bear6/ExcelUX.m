
classdef ExcelUX < handle

    properties (Constant)
        DATA_SOURCE_SHEET = "Data source"
        TASKS_SHEET = "Tasks"
        REDUCED_FORM_META_SHEET = "Reduced-form meta information"
        DUMMIES_SHEET = "Dummy observations"
        REDUCED_FORM_ESTIMATOR_SHEET = "Reduced-form estimation"
        STRUCTURAL_META_SHEET = "Structural meta information"

        CELL_READER_OPTIONS = {"Range", [1, 1], "TextType", "string", }

        INPUT_DATA_READER = struct( ...
            csv=@tablex.fromCsv ...
        );
    end


    properties
        FilePath (1, 1) string
        DataSource (:, :) cell
        Tasks (:, :) cell
        ReducedFormMeta (:, :) cell
        Estimator (:, :) cell
        Dummies (:, :) cell
        StructuralMeta (:, :) cell

        Config (1, 1) bear6.Config
        InputDataTable (:, :) timetable
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


        function readInputData(this, varargin)
            arguments
                this
            end
            arguments (Repeating)
                varargin
            end
            config = this.Config;
            reader = this.INPUT_DATA_READER.(lower(config.DataSource_Format));
            this.InputDataTable = reader(config.DataSource_FilePath, varargin{:});
        end%

    end


    methods (Access=protected)

        function readAll(this)
            this.readDataSource();
            this.readTasks();
            this.readReducedFormMeta();
            this.readEstimator();
            this.readDummies();
            this.readStructuralMeta();
        end%


        function readDataSource(this)
            this.DataSource = readcell( ...
                this.FilePath ...
                , "sheet", this.DATA_SOURCE_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readTasks(this)
            this.Tasks = readcell( ...
                this.FilePath ...
                , "sheet", this.TASKS_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readReducedFormMeta(this)
            this.ReducedFormMeta = readcell( ...
                this.FilePath ...
                , "sheet", this.REDUCED_FORM_META_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readDummies(this)
            this.Dummies = readcell( ...
                this.FilePath ...
                , "sheet", this.DUMMIES_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readEstimator(this)
            x = readcell( ...
                this.FilePath ...
                , "sheet", this.REDUCED_FORM_ESTIMATOR_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
            index = cellfun(@(x) isequal(x, true), x(2, :));
            if nnz(index) ~= 1
                error("Invalid selection of reduced-form estimation");
            end
            index = find(index, 1);
            this.Estimator = x(:, index-1:index);
        end%


        function readStructuralMeta(this)
            this.StructuralMeta = readcell( ...
                this.FilePath ...
                , "sheet", this.STRUCTURAL_META_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function configureAll(this)
            this.configureDataSource();
            this.configureTasks();
            this.configureReducedFormMeta();
            this.configureEstimator();
            this.configureStructuralMeta();
        end%


        function configureDataSource(this)
            this.Config.DataSource_Format = this.DataSource{2, 2};
            this.Config.DataSource_FilePath = this.DataSource{3, 2};
        end%


        function configureTasks(this)
            percentiles = reshape(double(split(string(this.Tasks{2, 2}), " ")), 1, []);
            this.Config.Tasks_Percentiles = percentiles;
        end%


        function configureReducedFormMeta(this)
            x = this.ReducedFormMeta;
            this.Config.ReducedFormMeta_Units = stringListFromCellArray(x(2, 2:end), whenEmpty="");
            this.Config.ReducedFormMeta_EndogenousConcepts = stringListFromCellArray(x(3, 2:end));
            this.Config.ReducedFormMeta_ExogenousNames = stringListFromCellArray(x(4, 2:end));
            this.Config.ReducedFormMeta_HasIntercept = x{5, 2};
            this.Config.ReducedFormMeta_Order = x{6, 2};
            this.Config.ReducedFormMeta_EstimationStart = x{7, 2};
            this.Config.ReducedFormMeta_EstimationEnd = x{8, 2};
        end%


        function configureEstimator(this)
            this.Config.Estimator_Name = string(this.Estimator{3, 2});
            settings = cell.empty(1, 0);
            for row = 6 : height(this.Estimator)
                if ismissing(this.Estimator{row, 1})
                    continue
                end
                settingName = string(this.Estimator{row, 1});
                if strlength(settingName) == 0
                    continue
                end
                settingValue = this.Estimator{row, 2};
                settings = [settings, {settingName, settingValue}];
            end
            this.Config.Estimator_Settings = settings;
        end%


        function configureStructuralMeta(this)
            x = this.StructuralMeta;
            this.Config.StructuralMeta_ShockConcepts = stringListFromCellArray(x(2, 2:end));
            this.Config.StructuralMeta_IdentificationHorizon = x{3, 2};
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

