%{
%
% model.Structural  Class of structural VAR models
%
%}

classdef Structural < handle & model.PresampleMixin & model.TabulateMixin

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
                options.reducedForm (1, 1) model.ReducedForm
                options.identifier (1, 1) identifier.Base
            end
            %
            this.ReducedForm = options.reducedForm;
            this.Identifier = options.identifier;
        end%


        function resetPresampled(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
            end
            this.Presampled = cell(1, numToPresample);
            %this.ReducedForm.resetPresampled(numToPresample);
        end%


        function storePresampled(this, index, sample)
            this.Presampled{index} = sample;
            this.ReducedForm.storePresampled(index, sample);
        end%


        function varargout = initialize(this)
            this.ReducedForm.initialize();
            this.Identifier.initialize(this);
        end%


        function varargout = simulateResponses(this, varargin)
            meta = this.Meta;
            startPeriod = datex.shift(meta.EstimationEnd, 1);
            endPeriod = datex.shift(meta.EstimationEnd, meta.IdentificationHorizon);
            span = datex.span(startPeriod, endPeriod);
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @this.simulateResponses4S, ...
                "span", span, ...
                "variantDim", 4, ...
                "initiator", @zeros, ...
                "dimNames", {meta.EndogenousNames, meta.SeparableShockNames}, ...
                options{:} ...
            );
        end%


        function [y, sample] = simulateResponses4S(this, sample)
        % Simulate a numT x numY x numP x numUnits array of responses to
        % structural shocks for a single presampled system
            if ~isfield(sample, "IdentificationDraw")
                sample.IdentificationDraw = this.IdentificationDrawer(sample);
            end
            meta = this.Meta;
            draw = sample.IdentificationDraw;
            numP = meta.NumSeparableUnits;
            y = cell(1, numP);
            for i = 1 : numP
                unitA = meta.extractUnitFromCells(draw.A, i, dim=3);
                unitD = sample.D(:, :, i);
                y{i} = system.filterPulses(unitA, unitD);
            end
            y = cat(2, y{:});
        end%


        function [varargout] = estimateShocks(this, varargin)
%{
% # calculateShocks
%
% {==Estimate structural shocks==}
%
%}
            meta = this.Meta;
            longYXZ = this.DataHolder.getYXZ(span=meta.LongSpan);
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateShocks4S(sample, longYXZ);
            end%
            options = [{"includeInitial", false}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @zeros, ...
                "dimNames", {meta.ShockNames}, ...
                options{:} ...
            );
        end%


        function [e, sample] = estimateShocks4S(this, sample, longYXZ)
            u = this.ReducedForm.estimateResiduals4S(sample, longYXZ);
            D = sample.D;
            % U = E * D => E = U / D
            e = u / D;
        end%


        function outTbx = calculateContributions(this)
            meta = this.Meta;
            numV = this.NumPresampled;
            drawer = this.HistoryDrawer;
            longYXZ = this.getLongYXZ();
            %
            C = cell(1, numV);
            for i = 1 : numV
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


        % Legacy name
        function varargout = breakdown(varargin)
            [varargout{1:nargout}] = computeShockContributions(varargin{:});
        end%


        function C = calculateShockContributions4S(this, sample, shockEstimates)
            draw = this.HistoryDrawer(sample);
            C = system.contributionsShocks(draw.A, sample.D, shockEstimates);
        end%


        function varargout = calculateFEVD(this, varargin)
            meta = this.Meta;
            function [fevd, sample] = calculateFEVD4S(sample)
                [vma, sample] = this.simulateResponses4S(sample);
                fevd = system.finiteFEVD(vma);
            end%
            startPeriod = datex.shift(meta.EstimationEnd, 1);
            endPeriod = datex.shift(meta.EstimationEnd, meta.IdentificationHorizon);
            span = datex.span(startPeriod, endPeriod);
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculateFEVD4S, ...
                "span", span, ...
                "variantDim", 4, ...
                "initiator", @zeros, ...
                "dimNames", {meta.EndogenousNames, meta.SeparableShockNames}, ...
                options{:} ...
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
            numShockConcepts = meta.NumShockConcepts;
            %
            legacyOptions = struct();
            legacyOptions.hasIntercept = meta.HasIntercept;
            legacyOptions.order = meta.Order;
            legacyOptions.cfconds = [];
            legacyOptions.cfblocks = [];
            legacyOptions.cfshocks = [];
            %
            numV = this.NumPresampled;
            progressMessage = sprintf("Conditional forecast [%g]", numV);
            %
            %
            numUnits = meta.NumSeparableUnits;
            if numUnits > 1
                if ~isempty(cfconds)
                    cfconds = reshape(cfconds, size(cfconds, 1), [], numUnits);
                end
                if ~isempty(cfshocks)
                    cfshocks = reshape(cfshocks, size(cfshocks, 1), [], numUnits);
                end
                if ~isempty(cfblocks)
                    cfblocks = reshape(cfblocks, size(cfblocks, 1), [], numUnits);
                end
            end
            fcastY = cell(1, numV);
            fcastE = cell(1, numV);
            pbar = progress.Bar(progressMessage, numV*numUnits);
            for i = 1 : numV
                sample = this.Presampled{i};
                draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
                for j = 1 : numUnits
                    if ~isempty(cfconds)
                        legacyOptions.cfconds = cfconds(:, :, j);
                    end
                    if ~isempty(cfshocks)
                        legacyOptions.cfshocks = cfshocks(:, :, j);
                        for k = 1 : numel(legacyOptions.cfshocks)
                            legacyOptions.cfshocks{k} = legacyOptions.cfshocks{k} - (j-1)*numShockConcepts;
                        end
                    end
                    if ~isempty(cfblocks)
                        legacyOptions.cfblocks = cfblocks(:, :, j);
                    end
                    unitInitY = initY(:, :, j);
                    unitD = sample.D(:, :, j);
                    unitBeta = meta.extractUnitFromCells(draw.beta, j, dim=2);
                    unitBeta = [unitBeta{:}];
                    [unitY, unitE] = conditional.forecast(unitD, unitBeta, unitInitY, fcastX, fcastHorizon, legacyOptions);
                    fcastY{i} = [fcastY{i}, unitY];
                    fcastE{i} = [fcastE{i}, unitE];
                    pbar.increment();
                end
            end
            fcastY = cat(3, fcastY{:});
            fcastE = cat(3, fcastE{:});
            %
            %
            outNames = [meta.EndogenousNames, meta.ShockNames];
            outSpan = fcastSpan;
            if options.IncludeInitial
                initY = initY(:, :);
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

