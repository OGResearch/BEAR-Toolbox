
classdef ...
    (CaseInsensitiveProperties=true) ...
    Meta

    properties (Dependent)
        % Diplay of endogenous names
        Endogenous

        % Diplay of exogenous names
        Exogenous
    end

    properties (Hidden)
        % Names of endogenous variables
        EndogenousItems (1, :) cell

        % Names of exogenous variables
        ExogenousItems (1, :) cell = cell.empty(1, 0)
    end

    properties
        % Order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
    end

    properties (Dependent, Hidden)
        % Number of endogenous variables
        HasConstant

        % Number of endogenous data columns
        NumEndogenousColumns

        % Number of exogenous data columns
        NumExogenousColumns

        % Number of columns in the LHS data array
        NumLhsColumns

        % Number of columns in the RHS data array
        NumRhsColumns

        % Transition matrices
        SizeA
        NumelA
        IndexA

        % Multipliers of exogenous variables
        SizeC
        NumelC
        IndexC

        % Covariance matrix of reduced-form residuals
        SizeSigma
        NumelSigma
        IndexSigma
    end

    methods
        function this = Meta(options)
            arguments
                options.Endogenous (1, :) = string.empty(1, 0)
                options.Exogenous (1, :) = string.empty(1, 0)
                options.Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
                options.Constant (1, 1) logical = false
            end

            if isempty(options.Endogenous)
                error("At least one endogenous variable must be specified");
            end
            this.EndogenousItems = item.fromUserInput(options.Endogenous);
            this.ExogenousItems = item.fromUserInput(options.Exogenous);
            if options.Constant
                this.ExogenousItems{end+1} = item.Constant();
            end
            this.Order = options.Order;
        end%

        function YX = getData(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.RemoveMissing (1, 1) logical = true
                options.Variant (1, 1) double = 1
            end

            numPeriods = numel(periods);
            Y = nan(numPeriods, 0);
            X = nan(numPeriods, 0);

            % LHS array - current endogenous items
            for i = 1:numel(this.EndogenousItems)
                item = this.EndogenousItems{i};
                Y = [Y, item.getData(dataTable, periods, variant=options.Variant)];
            end

            % RHS array - lags of endogenous items
            for lag = 1:this.Order
                for i = 1:numel(this.EndogenousItems)
                    item = this.EndogenousItems{i};
                    X = [X, item.getData(dataTable, periods, variant=options.Variant, shift=-lag)];
                end
            end

            % RHS array - exogenous items
            for i = 1:numel(this.ExogenousItems)
                item = this.ExogenousItems{i};
                X = [X, item.getData(dataTable, periods, variant=options.Variant)];
            end

            if options.RemoveMissing
                inxMissing = any(isnan(Y), 2) | any(isnan(X), 2);
                Y(inxMissing, :) = [];
                X(inxMissing, :) = [];
            end

            YX = {Y, X};
        end%
    end

    methods
        function flag = get.HasConstant(this)
            for item = this.ExogenousItems
                if isa(item{:}, "item.Constant")
                    flag = true;
                    return
                end
            end
            flag = false;
        end%

        function num = get.NumEndogenousColumns(this)
            num = 0;
            for i = 1:numel(this.EndogenousItems)
                num = num + this.EndogenousItems{i}.NumColumns;
            end
        end%

        function num = get.NumExogenousColumns(this)
            num = 0;
            for i = 1:numel(this.ExogenousItems)
                num = num + this.ExogenousItems{i}.NumColumns;
            end
        end%

        function num = get.NumLhsColumns(this)
            num = this.NumEndogenousColumns;
        end%

        function num = get.NumRhsColumns(this)
            num = this.NumEndogenousColumns*this.Order + this.NumExogenousColumns;
        end%

        function siz = get.SizeA(this)
            numEndogenousColumns = this.NumEndogenousColumns;
            siz = [numEndogenousColumns, numEndogenousColumns, this.Order];
        end%

        function num = get.NumelA(this)
            num = prod(this.SizeA);
        end%

        function ind = get.IndexA(this)
            ind = 1 : this.NumelA;
        end%

        function siz = get.SizeC(this)
            siz = [this.NumEndogenousColumns, this.NumExogenousColumns];
        end%

        function num = get.NumelC(this)
            num = prod(this.SizeC);
        end%

        function ind = get.IndexC(this)
            ind = this.NumelA + (1 : this.NumelC);
        end%

        function siz = get.SizeSigma(this)
            numEndogenousColumns = this.NumEndogenousColumns;
            siz = [numEndogenousColumns, numEndogenousColumns];
        end%

        function num = get.NumelSigma(this)
            num = prod(this.SizeSigma);
        end%

        function ind = get.IndexSigma(this)
            ind = this.NumelA + this.NumelC + (1 : this.NumelSigma);
        end%

        function repr = get.Endogenous(this)
            numEndogenousItems = numel(this.EndogenousItems);
            repr = cell(1, numEndogenousItems);
            for i = 1:numEndogenousItems
                repr{i} = this.EndogenousItems{i}.DisplayName;
            end
        end%

        function repr = get.Exogenous(this)
            numExogenousItems = numel(this.ExogenousItems);
            repr = cell(1, numExogenousItems);
            for i = 1:numExogenousItems
                repr{i} = this.ExogenousItems{i}.DisplayName;
            end
        end%
    end

end

