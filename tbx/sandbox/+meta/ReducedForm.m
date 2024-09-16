
% meta.ReducedForm  Meta class for reduced-form VAR models

classdef ReducedForm < handle

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
        ResidualPrefix (1, 1) string = "resid_"
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
        NumResidualColumns
    end

    methods
        function this = ReducedForm(options)
            arguments
                options.Endogenous (1, :) = string.empty(1, 0)
                options.Exogenous (1, :) = string.empty(1, 0)
                options.Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1
                options.Constant (1, 1) logical = true
            end
            %
            if isempty(options.Endogenous)
                error("At least one endogenous variable must be specified");
            end
            %
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

        function initYLX = getInitYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.Variant (1, :) double = 1
            end
            %
            % Create initial condition span
            order = this.Order;
            startPeriod = periods(1);
            initSpan = datex.span( ...
                datex.shift(startPeriod, -order) ...
                ,  datex.shift(startPeriod, -1) ...
            );
            %
            % Call getDataYLX to get initial condition data
            initYLX = this.getDataYLX( ...
                dataTable, initSpan ...
                , variant=options.Variant ...
                , removeMissing=false ...
            );
        end%

        function [YLX, periods] = getDataYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.RemoveMissing (1, 1) logical = true
                options.Variant (1, :) double = 1
            end
            %
            numPeriods = numel(periods);
            Y = nan(numPeriods, 0);
            L = nan(numPeriods, 0);
            X = nan(numPeriods, 0);
            %
            % LHS array - current endogenous items
            for i = 1:numel(this.EndogenousItems)
                item = this.EndogenousItems{i};
                Y = [Y, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % RHS array - lags of endogenous items
            for lag = 1:this.Order
                for i = 1:numel(this.EndogenousItems)
                    item = this.EndogenousItems{i};
                    L = [L, item.getData(dataTable, periods, variant=options.Variant, shift=-lag)];
                end
            end
            %
            % RHS array - exogenous items
            for i = 1:numel(this.ExogenousItems)
                item = this.ExogenousItems{i};
                X = [X, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % Remove rows with missing observations to prepare the data for
            % estimation
            if options.RemoveMissing
                inxMissing = any(isnan(Y), 2) | any(isnan(L), 2) | any(isnan(X), 2);
                Y(inxMissing, :) = [];
                L(inxMissing, :) = [];
                X(inxMissing, :) = [];
                periods(inxMissing) = [];
            end
            %
            YLX = {Y, L, X};
        end%

        function emptyYLX = createEmptyYLX(this)
            numY = this.NumEndogenousColumns;
            numL = this.NumEndogenousColumns * this.Order;
            numX = this.NumExogenousColumns;
            numT = 0;
            emptyYLX = { ...
                nan(numT, numY), ...
                nan(numT, numL), ...
                nan(numT, numX), ...
            };
        end%

        function A = ayeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
        end%

        function [A, C] = ayeCeeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
            C = B(this.SizeA(1)+1:end, :);
        end%

        function Sigma = sigmaFromSample(this, sample)
            Sigma = reshape(sample{2}, this.SizeSigma);
        end%

        function system = systemFromSample(this, sample)
            [A, C] = this.ayeCeeFromSample(sample);
            Sigma = reshape(sample{2}, this.SizeSigma);
            system = {A, C, Sigma};
        end%

        function sample = preallocateRedSample(this, numSamples)
            sample = {nan(this.NumelB, numSamples), nan(this.NumelSigma, numSamples)};
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
            ];
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

        function names = get.NumResidualColumns(this)
            names = this.NumEndogenousColumns;
        end%
    end

end

