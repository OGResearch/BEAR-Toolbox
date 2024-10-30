%{
%
% model.Structural  Class of structural VAR models
%
%}

classdef Structural < handle & model.PresampleMixin

    properties
        Meta
        ReducedForm
        Identifier
        Presampled
    end


    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end


    methods

        function this = Structural(options)
            arguments
                options.Meta (1, 1) meta.Structural
                options.ReducedForm (1, 1) model.ReducedForm
                options.Identifier (1, 1) identifier.Base
            end
            %
            this.Meta = options.Meta;
            this.ReducedForm = options.ReducedForm;
            this.Identifier = options.Identifier;
            this.Identifier.finalize(this.ReducedForm);
        end%


        function resetPresampled(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
            end
            this.Presampled = cell(1, numToPresample);
            this.ReducedForm.resetPresampled(numToPresample);
        end%


        function storePresampled(this, index, sample)
            this.Presampled{index} = sample;
            this.ReducedForm.storePresampled(index, sample);
        end%


        function varargout = initialize(this, varargin)
            this.ReducedForm.initialize();
            this.Identifier.initialize(this.Meta, this.ReducedForm);
        end%


        function sampler = getSampler(this)
            sampler = this.Identifier.Sampler;
        end%


        function outTbx = simulateResponses(this, options)
            %[
            arguments
                this
                options.IncludeInitial (1, 1) logical = true
                options.Transform = []
            end
            %
            numY = this.ReducedForm.Meta.NumEndogenousNames;
            order = this.ReducedForm.Meta.Order;
            numE = this.Meta.NumShocks;
            numT = this.Meta.IdentificationHorizon;
            numPresampled = this.NumPresampled;
            drawer = @(sample) this.ReducedForm.Estimator.IdentificationDrawer(sample, numT);
            %
            Y = nan(numT, numY, numE, numPresampled);
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                D = sample.D;
                y = system.finiteVMA(draw.A, D);
                if ~isempty(options.Transform)
                    y = options.Transform(y);
                end
                Y(:, :, :, i) = y;
            end
            %
            shortStart = datex.shift(this.ReducedForm.Meta.EstimationEnd, 1);
            shortEnd = datex.shift(this.ReducedForm.Meta.EstimationEnd, numT);
            outSpan = datex.span(shortStart, shortEnd);
            if options.IncludeInitial
                Y = [zeros(order, numY, numE, numPresampled); Y];
                outSpan = datex.longSpanFromShortSpan(outSpan, order);
            end
            %
            outShockNames = this.Meta.ShockNames;
            outNames = this.ReducedForm.Meta.EndogenousNames;
            outTbx = tablex.fromNumericArray(Y, outNames, outSpan, variantDim=4);
            outTbx = tablex.setHigherDims(outTbx, outShockNames);
            %]
        end%


        function outTbx = calculateShocks(this, varargin)
%{
% # calculateResiduals
%
% {==Calculate reduced-form residuals==}
%
%}
            E = this.calculateShockArray(varargin{:});
            outNames = this.Meta.ShockNames;
            outSpan = this.ReducedForm.Meta.ShortSpan;
            outTbx = tablex.fromNumericArray(E, outNames, outSpan, variantDim=3);
        end%


        function E = calculateShockArray(this, varargin)
            U = this.ReducedForm.calculateResidualArray(varargin{:});
            numPresampled = this.NumPresampled;
            E = nan(size(U));
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                D = sample.D;
                % U = E * D => E = U / D
                E(:, :, i) = U(:, :, i) / D;
            end
        end%


        function outTbx = calculateShockContributions(this, varargin)
            C = this.calculateShockContributionArray(varargin{:});
            outTbx = tablex.fromNumericArray( ...
                C ...
                , this.ReducedForm.Meta.EndogenousNames ...
                , this.ReducedForm.Meta.ShortSpan ...
                , variantDim=4 ...
            );
            outTbx = tablex.setHigherDims(outTbx, this.Meta.ShockNames);
        end%


        function C = calculateShockContributionArray(this, options)
            arguments
                this
                options.shocks (:, :) double = []
            end
            %
            if isempty(options.shocks)
                E = this.calculateShockArray();
            else
                E = options.shocks;
            end
            %
            numT = size(E, 1);
            numPresampled = this.NumPresampled;
            numE = this.Meta.NumShocks;
            numY = this.ReducedForm.Meta.NumEndogenousNames;
            C = cell(1, numPresampled);
            drawer = @(sample) this.ReducedForm.Estimator.IdentificationDrawer(sample, numT);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                C{i} = system.contributionsShocks(draw.A, sample.D, E(:, :, i));
            end
            C = cat(4, C{:});
        end%


        function outTbx = calculateFEVD(this, varargin)
            transform = @(vma) cumsum(vma .^ 2, 1);
            outTbx = this.simulateResponses(varargin{:}, transform=transform);
        end%


        function [sampler, shockIndex] = getSamplerVMA(this, numPeriods, shockIndex)
            arguments
                this
                numPeriods (1, 1) double
                shockIndex (1, :)
            end
            %
            shockIndex = names.resolveNameIndex(this.Meta.ShockNames, shockIndex);
            %
            function VMA = sampleVMA()
                strSystem = this.nextPresampledSystem();
                [A, C, Sigma, D, stdVec] = strSystem{:};
                VMA = system.finiteVMA(A, D(shockIndex, :), numPeriods);
            end%
            %
            sampler = @sampleVMA;
        end%


        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
        end%


        function varargout = forecast(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.forecast(varargin{:});
        end%

        function varargout = calculateResiduals(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.calculateResiduals(varargin{:});
        end%

    end

end

