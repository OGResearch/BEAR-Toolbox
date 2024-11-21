%{
%
% model.Structural  Class of structural VAR models
%
%}

classdef Structural < handle & model.PresampleMixin

    properties
        ReducedForm
        Identifier
        Presampled (1, :) cell = cell.empty(1, 0)
    end


    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    properties (Dependent)
        Meta
        Estimator
        DataHolder
        %
        Sampler
        SampleCounter
        CandidateCounter
        IdentificationDrawer
        HistoryDrawer
        ConditionalDrawer
        UnconditionalDrawer
    end

    methods

        function this = Structural(options)
            arguments
                options.ReducedForm (1, 1) model.ReducedForm
                options.Identifier (1, 1) identifier.Base
            end
            %
            this.ReducedForm = options.ReducedForm;
            this.Identifier = options.Identifier;
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


        function varargout = initialize(this)
            this.ReducedForm.initialize();
            this.Identifier.initialize(this);
        end%


        function outTbx = simulateResponses(this, options)
            %[
            arguments
                this
                %
                options.IncludeInitial (1, 1) logical = true
                options.Transform = []
            end
            %
            meta = this.Meta;
            numY = meta.NumEndogenousNames;
            order = meta.Order;
            numE = meta.NumShocks;
            numT = meta.IdentificationHorizon;
            numPresampled = this.NumPresampled;
            drawer = this.IdentificationDrawer;
            %
            Y = nan(numT, numY, numE, numPresampled);
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [Y4S, sample] = this.simulateResponses4S(sample);
                this.Presampled{i} = sample;
                if ~isempty(options.Transform)
                    Y4S = options.Transform(Y4S);
                end
                Y(:, :, :, i) = Y4S;
            end
            %
            shortStart = datex.shift(meta.EstimationEnd, 1);
            shortEnd = datex.shift(meta.EstimationEnd, numT);
            outSpan = datex.span(shortStart, shortEnd);
            if options.IncludeInitial
                Y = [zeros(order, numY, numE, numPresampled); Y];
                outSpan = datex.longSpanFromShortSpan(outSpan, order);
            end
            %
            outShockNames = meta.ShockNames;
            outNames = meta.EndogenousNames;
            outTbx = tablex.fromNumericArray(Y, outNames, outSpan, variantDim=4);
            outTbx = tablex.setHigherDims(outTbx, outShockNames);
            %]
        end%


        function [Y4S, sample] = simulateResponses4S(this, sample)
        % Simulate a numT x numY x numP x numUnits array of responses to
        % structural shocks for a single presampled system
            if ~isfield(sample, "IdentificationDraw")
                sample.IdentificationDraw = this.IdentificationDrawer(sample);
            end
            draw = sample.IdentificationDraw;
            % Array Y4S is numT x numY x numP x numUnits
            Y4S = system.finiteVMA(draw.A, sample.D);
        end%


        function outTbx = estimateShocks(this, varargin)
%{
% # calculateShocks
%
% {==Estimate structural shocks==}
%
%}
            meta = this.Meta;
            longYXZ = this.DataHolder.getYXZ(span=meta.LongSpan);
            E = nan(meta.NumShortSpan, meta.NumShocks, this.NumPresampled);
            for i = 1 : this.NumPresampled
                sample = this.Presampled{i};
                E(:, :, i) = this.estimateShocks4S(sample, longYXZ);
            end
            outNames = meta.ShockNames;
            outSpan = meta.ShortSpan;
            outTbx = tablex.fromNumericArray(E, outNames, outSpan, variantDim=3);
        end%


        function e = estimateShocks4S(this, sample, longYXZ)
            u = this.ReducedForm.estimateResiduals4S(sample, longYXZ);
            D = sample.D;
            % U = E * D => E = U / D
            e = u / D;
        end%


        function outTbx = breakdown(this)
            meta = this.Meta;
            numPresampled = this.NumPresampled;
            drawer = this.HistoryDrawer;
            longYXZ = this.getLongYXZ();
            %
            C = cell(1, numPresampled);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                e = this.estimateShocks4S(sample, longYXZ);
                ce = system.contributionsShocks(draw.A, sample.D, e);
                cx = system.contributionsExogenous(draw.A, draw.C, longYXZ);
                ci = system.contributionsInit(draw.A, longYXZ);
                C{i} = cat(3, ce, cx, ci);
            end
            %
            thirdDim = {[meta.ShockNames, "Exogenous", "Initials"]};
            outTbx = tablex.fromNumericArray( ...
                cat(4, C{:}), ...
                meta.EndogenousNames, ...
                meta.ShortSpan, ...
                variantDim=4, ...
                higherDims=thirdDim ...
            );
        end%


        function C = breakdownToShocks4S(this, sample, shockEstimates)
            draw = this.HistoryDrawer(sample);
            C = system.contributionsShocks(draw.A, sample.D, shockEstimates);
        end%


        function outTbx = calculateFEVD(this, varargin)
            transform = @(vma) cumsum(vma .^ 2, 1);
            outTbx = this.simulateResponses( ...
                includeInitial=false, ...
                transform=transform ...
            );
        end%

        function outTbx = conditionalForecast(this, fcastSpan, options)
            %[
            arguments
                this
                fcastSpan (1, :) datetime
                options.Conditions (:, :) timetable
                options.Plan = []
                options.IncludeInitial (1, 1) logical = true
            end
            %
            meta = this.Meta;
            fcastStart = fcastSpan(1);
            fcastEnd = fcastSpan(end);
            fcastSpan = datex.span(fcastStart, fcastEnd);
            fcastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            fcastHorizon = numel(fcastSpan);
            initSpan = datex.initSpanFromShortSpan(fcastSpan, meta.Order);
            initYXZ = this.getSomeYXZ(initSpan);
            initY = initYXZ{1};
            fcastX = tablex.retrieveData(options.Conditions, meta.ExogenousNames, fcastSpan);
            %
            cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, fcastSpan);
            cfshocks = conditional.createShocksCF(meta, options.Plan, fcastSpan);
            cfblocks = conditional.createBlocksCF(cfconds, cfshocks);
            %
            legacyOptions = struct();
            legacyOptions.hasIntercept = meta.HasIntercept;
            legacyOptions.order = meta.Order;
            legacyOptions.cfconds = cfconds;
            legacyOptions.cfblocks = cfblocks;
            legacyOptions.cfshocks = cfshocks;
            %
            numPresampled = this.NumPresampled;
            progressMessage = sprintf("Conditional forecast [%g]", numPresampled);
            pbar = progress.Bar(progressMessage, numPresampled);
            %
            fcastY = cell(1, numPresampled);
            fcastE = cell(1, numPresampled);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
                D = sample.D;
                beta_iter = [draw.beta{:}];
                [fcastY{i}, fcastE{i}] = conditional.forecast(D, beta_iter, initY, fcastX, fcastHorizon, legacyOptions);
                pbar.increment();
            end
            %
            fcastY = cat(3, fcastY{:});
            fcastE = cat(3, fcastE{:});
            %
            outNames = [meta.EndogenousNames, meta.ShockNames];
            outSpan = fcastSpan;
            if options.IncludeInitial
                fcastY = [repmat(initY, 1, 1, size(fcastY, 3)); fcastY];
                fcastE = [zeros(meta.Order, size(fcastE, 2), size(fcastE, 3)); fcastE];
                outSpan = datex.longSpanFromShortSpan(fcastSpan, meta.Order);
            end
            outTbx = tablex.fromNumericArray([fcastY, fcastE], outNames, outSpan, variantDim=3);
            %]
        end%

        % function [sampler, shockIndex] = getSamplerVMA(this, numPeriods, shockIndex)
        %     arguments
        %         this
        %         numPeriods (1, 1) double
        %         shockIndex (1, :)
        %     end
        %     %
        %     meta = this.Meta;
        %     shockIndex = textual.resolveNameIndex(meta.ShockNames, shockIndex);
        %     %
        %     function VMA = sampleVMA()
        %         strSystem = this.nextPresampledSystem();
        %         [A, C, Sigma, D, stdVec] = strSystem{:};
        %         VMA = system.finiteVMA(A, D(shockIndex, :), numPeriods);
        %     end%
        %     %
        %     sampler = @sampleVMA;
        % end%


        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
        end%

        function varargout = forecast(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.forecast(varargin{:});
        end%

        function varargout = estimateResiduals(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.estimateResiduals(varargin{:});
        end%

        function varargout = getLongYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getLongYXZ(varargin{:});
        end%

        function varargout = getShortYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getShortYXZ(varargin{:});
        end%

        function varargout = getSomeYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getSomeYXZ(varargin{:});
        end%

        function varargout = getInitYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getInitYXZ(varargin{:});
        end%
    end


    methods
        function out = get.Meta(this)
            out = this.ReducedForm.Meta;
        end%

        function out = get.Estimator(this)
            out = this.ReducedForm.Estimator;
        end%

        function out = get.DataHolder(this)
            out = this.ReducedForm.DataHolder;
        end%

        function out = get.Sampler(this)
            out = this.Identifier.Sampler;
        end%

        function out = get.SampleCounter(this)
            out = this.Identifier.SampleCounter;
        end%

        function out = get.CandidateCounter(this)
            out = this.Identifier.CandidateCounter;
        end%

        function out = get.IdentificationDrawer(this)
            out = this.ReducedForm.IdentificationDrawer;
        end%

        function out = get.HistoryDrawer(this)
            out = this.ReducedForm.HistoryDrawer;
        end%

        function out = get.ConditionalDrawer(this)
            out = this.ReducedForm.ConditionalDrawer;
        end%

        function out = get.UnconditionalDrawer(this)
            out = this.ReducedForm.UnconditionalDrawer;
        end%
    end

end

