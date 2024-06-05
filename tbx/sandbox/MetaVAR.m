
classdef MetaVAR

    properties
        % Names of endogenous variables
        EndogenousItems (1, :) cell

        % Names of exogenous variables
        ExogenousItems (1, :) cell = cell.empty(1, 0)

        % Order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
    end

    properties (Dependent, Hidden)
        NumEndogenousColumns    % Number of endogenous data columns
        NumExogenousColumns     % Number of exogenous data columns

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
        function this = MetaVAR(endogenousItems, options)
            arguments
                endogenousItems (1, :)
                options.ExogenousItems (1, :) = string.empty(1, 0)
                options.Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
                options.Constant (1, 1) logical = false
            end
            % Constructor method to initialize the MetaVAR object
            if nargin > 0
                this.EndogenousItems = item.fromStrings(endogenousItems);
                this.ExogenousItems = item.fromStrings(options.ExogenousItems);
                if options.Constant
                    this.ExogenousItems{end+1} = item.Constant();
                end
                this.Order = options.Order;
            end
        end%

        function [Y, X] = getData(this, dataTable, periods, options)
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
    end

    methods
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
    end

end

