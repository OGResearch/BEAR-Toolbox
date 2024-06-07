
classdef ...
    (CaseInsensitiveProperties=true) ...
    Meta < handle

    properties (Dependent)
        % Diplay of endogenous names
        EndogenousNames

        % Diplay of exogenous names
        ExogenousNames
    end

    properties (Hidden)
        % Endogenous items
        EndogenousItems (1, :) cell

        % Exogenous items
        ExogenousItems (1, :) cell = cell.empty(1, 0)

        % Residual prefix
        ResidualPrefix (1, 1) string = "res_"
    end

    properties
        % Order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
    end

    properties (Hidden, SetAccess=private)
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

        % Multipliers of exogenous variables
        SizeC
        NumelC

        % Covariance matrix of reduced-form residuals
        SizeSigma
        NumelSigma

        % Combined transition matrices and multipliers
        SizeB
        NumelB

        % Number of elements in the vector of parameters
        NumelTheta
    end

    properties (Dependent, Hidden)
        ResidualNames
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
            this.populateProperties();
        end%

        function populateProperties(this)
            this.assignHasConstant();
            this.assignNumEndogenousColumns();
            this.assignNumExogenousColumns();
            this.assignNumLhsColumns();
            this.assignNumRhsColumns();

            this.assignSizeA();
            this.assignSizeC();
            this.assignSizeSigma();
            this.assignSizeB();

            this.assignNumelA();
            this.assignNumelC();
            this.assignNumelSigma();
            this.assignNumelB();

            this.assignNumelTheta();
        end%

        function YX = getDataYX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.RemoveMissing (1, 1) logical = true
                options.Variant (1, :) double = 1
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

        function A = ayeFromTheta(this, theta)
            B = reshape(theta(1:this.NumelB), this.SizeB);
            A = B(1:this.SizeA(1), :);
        end%

        function [A, C] = ayeCeeFromTheta(this, theta)
            B = reshape(theta(1:this.NumelB), this.SizeB);
            A = B(1:this.SizeA(1), :);
            C = B(this.SizeA(1)+1:end, :);
        end%

        function Sigma = sigmaFromTheta(this, theta)
            Sigma = reshape(theta(this.NumelB+1:end), this.SizeSigma);
        end%

        function [A, C, Sigma] = ayeCeeSigmaFromTheta(this, theta)
            B = reshape(theta(1:this.NumelB), this.SizeB);
            A = B(1:this.SizeA(1), :);
            C = B(this.SizeA(1)+1:end, :);
            Sigma = reshape(theta(this.NumelB+1:end), this.SizeSigma);
        end%
    end

    methods
        function assignHasConstant(this)
            flag = false;
            for item = this.ExogenousItems
                if isa(item{:}, "item.Constant")
                    flag = true;
                end
            end
            this.HasConstant = flag;
        end%

        function assignNumEndogenousColumns(this)
            num = 0;
            for i = 1:numel(this.EndogenousItems)
                num = num + this.EndogenousItems{i}.NumColumns;
            end
            this.NumEndogenousColumns = num;
        end%

        function assignNumExogenousColumns(this)
            num = 0;
            for i = 1:numel(this.ExogenousItems)
                num = num + this.ExogenousItems{i}.NumColumns;
            end
            this.NumExogenousColumns = num;
        end%

        function assignNumLhsColumns(this)
            this.NumLhsColumns = this.NumEndogenousColumns;
        end%

        function assignNumRhsColumns(this)
            this.NumRhsColumns = ...
                + this.Order*this.NumEndogenousColumns ...
                + this.NumExogenousColumns;
        end%

        function assignSizeA(this)
            this.SizeA = [ ...
                this.Order * this.NumEndogenousColumns, ...
                this.NumEndogenousColumns, ...
            ]
        end%

        function assignSizeC(this)
            this.SizeC = [ ...
                this.NumExogenousColumns, ...
                this.NumEndogenousColumns, ...
            ];
        end%

        function assignSizeSigma(this)
            this.SizeSigma = [ ...
                this.NumEndogenousColumns, ...
                this.NumEndogenousColumns, ...
            ];
        end%

        function assignSizeB(this)
            this.SizeB = [ ...
                this.SizeA(1) + this.SizeC(1), ...
                this.NumEndogenousColumns, ...
            ];
        end%

        function assignNumelA(this)
            this.NumelA = prod(this.SizeA);
        end%

        function assignNumelC(this)
            this.NumelC = prod(this.SizeC);
        end%

        function assignNumelSigma(this)
            this.NumelSigma = prod(this.SizeSigma);
        end%

        function assignNumelB(this)
            this.NumelB = this.NumelA + this.NumelC;
        end%

        function assignNumelTheta(this)
            this.NumelTheta = this.NumelB + this.NumelSigma;
        end%
    end

    methods
        function repr = get.EndogenousNames(this)
            numEndogenousItems = numel(this.EndogenousItems);
            repr = string.empty(1, 0);
            for i = 1:numEndogenousItems
                repr = [repr, this.EndogenousItems{i}.DisplayName];
            end
        end%

        function repr = get.ExogenousNames(this)
            numExogenousItems = numel(this.ExogenousItems);
            repr = string.empty(1, 0);
            for i = 1:numExogenousItems
                repr = [repr, this.ExogenousItems{i}.DisplayName];
            end
        end%

        function names = get.ResidualNames(this)
            names = this.ResidualPrefix + this.EndogenousNames;
        end%
    end

end

