
classdef Structural < handle

    properties
        Meta
        ReducedForm
        Identifier
        Presampled
    end


    properties (Dependent)
        NumPresampled (1, 1) double
    end


    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end


    methods
        function this = Structural(options)
            arguments
                options.Meta (1, 1) meta.Structural
                options.ReducedForm (1, 1) model.ReducedForm
                options.Identification (1, 1) identification.Base
            end
            %
            this.Meta = options.Meta;
            this.ReducedForm = options.ReducedForm;
            this.Identifier = options.Identification;
            this.Identifier.finalizeFromMetaAndReducedForm(this.Meta, this.ReducedForm);
        end%

        function varargout = initialize(this, varargin)
            redModel = this.ReducedForm;
            [YLX, initYLX, dummiesYLX] = redModel.initialize(varargin{:});
            this.Identifier.initializePreallocator(YLX);
            this.Identifier.initializeSampler(redModel, YLX);
        end%

        function resetPresampledCounter(this)
            this.PresampledCounter = 0;
        end%

        function preallocatePresampled(this, numPresampled)
            this.Presampled = this.Identifier.Preallocator(numPresampled);
            this.resetPresampledCounter();
        end%

        function savePresampled(this, sample, index)
            for j = 1 : numel(this.Presampled)
                this.Presampled{j}(:, index, :) = sample{j};
            end
        end%

        function presampled = presample(this, numPresampled)
            this.preallocatePresampled(numPresampled);
            this.ReducedForm.preallocatePresampled(numPresampled);
            sampler = this.Identifier.Sampler;
            for i = 1 : numPresampled
                [strSample, redSample] = sampler();
                this.ReducedForm.savePresampled(redSample, i);
                this.savePresampled(strSample, i);
            end
            this.resetPresampledCounter();
        end%

        function [strSystem, redSystem] = nextPresampledSystem(this)
            this.ReducedForm.PresampledCounter = this.PresampledCounter;
            redSystem = this.ReducedForm.nextPresampledSystem();
            numY = this.ReducedForm.Meta.NumEndogenousColumns;
            numE = numY;
            sizePresampled = numel(this.Presampled);
            presampled = cell(1, sizePresampled);
            index = this.PresampledCounter + 1;
            for i = 1 : sizePresampled
                presampled{i} = this.Presampled{i}(:, index, :);
            end
            strSystem = { reshape(presampled{1}, numE, numY) };
            this.PresampledCounter = this.PresampledCounter + 1;
        end%

        function outTable = simulateShocks(this, span, options)
            arguments
                this
                span (1, :)
                options.ShockIndex (1, :) = Inf
                options.IncludeInitial (1, 1) logical = true
                options.Transform = []
            end

            numPeriods = numel(span);
            numY = this.ReducedForm.Meta.NumEndogenousColumns;
            numPresampled = this.NumPresampled;
            [samplerVMA, shockIndex] = this.getSamplerVMA(numPeriods, options.ShockIndex);
            numSimulatedE = numel(shockIndex);
            Y = nan(numPeriods, numY, numSimulatedE, numPresampled);

            for i = 1 : numPresampled
                y = samplerVMA();
                if ~isempty(options.Transform)
                    y = options.Transform(y, shockIndex);
                end
                Y(:, :, :, i) = y;
            end

            outSpan = span;
            if options.IncludeInitial
                Y = [zeros(1, numY, numSimulatedE, numPresampled); Y];
                outSpan = [datex.shift(outSpan(1), -1), outSpan];
            end

            outShockNames = this.Meta.ShockNames(shockIndex);
            outNames = this.ReducedForm.Meta.EndogenousNames;
            variantDim = 4;
            outTable = tablex.fromNumericArray(Y, outNames, outSpan, variantDim);
            outTable = tablex.setCustom(outTable, "HigherDims", {outShockNames});
        end%

        function outTable = fevd(this, varargin)
            varVec = this.Identifier.VarVec;
            function Y = transform(Y, shockIndex)
                % TODO: Refactor
                % numPeriods = size(Y, 1);
                % numY = size(Y, 2);
                % varVec = modelVarVec(shockIndex);
                % varMat = repmat(reshape(varVec, 1, []), numY, 1);
                % varMat = permute(varMat, [3, 1, 2]);
                % varMat = repmat(varMat, numPeriods, 1, 1);
                % Y = cumsum(Y .^ 2, 1) .* varMat;
                Y = system.fevdFromVma(Y, varVec, shockIndex);
            end%
            outTable = this.simulateShocks(varargin{:}, transform=@transform);
        end%

        function [outSamplerVMA, shockIndex] = getSamplerVMA(this, numPeriods, shockIndex)
            arguments
                this
                numPeriods (1, 1) double
                shockIndex (1, :)
            end

            shockNames = this.Meta.ShockNames;
            shockIndex = names.resolveNameIndex(shockNames, shockIndex);
            this.resetPresampledCounter();

            function VMA = sampleVMA()
                [strSystem, redSystem] = this.nextPresampledSystem();
                A = redSystem{1};
                D = strSystem{1}(shockIndex, :);
                VMA = system.simulateShocks(A, D, numPeriods);
            end%

            outSamplerVMA = @sampleVMA;
        end%

        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
        end%

        function varargout = forecast(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.forecast(varargin{:});
        end%
    end


    methods
        function num = get.NumPresampled(this)
            num = size(this.Presampled{1}, 2);
        end%
    end

end

