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
            this.Identifier.whenPairedWithModel(this);
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
            meta = this.Meta;
            numP = meta.NumSeparableUnits;
            e = cell(1, numP);
            u = meta.reshapeCrossUnitData(u);
            for i = 1 : numP
                unitD = sample.D(:, :, i);
                unitU = u(:, :, i);
                e{i} = system.shocksFromResiduals(unitU, unitD);
            end
            e = cat(3, e{:});
        end%


        function contribsTbl = calculateContributions(this, options)
            arguments
                this
                options.IncludeInitial (1, 1) logical = true
            end
            meta = this.Meta;
            numPresampled = this.NumPresampled;
            drawer = this.HistoryDrawer;
            longYXZ = this.getLongYXZ();
            order = meta.Order;
            %
            [contributor, contribs] = this.prepareForContributions(meta.ShortSpan, []);
            numUnits = meta.NumSeparableUnits;
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                shortE = this.estimateShocks4S(sample, longYXZ);
                % initY = longYXZ{1}(1:order, :, :);
                % shortX = longYXZ{2}(order+1:end, :, :);
                % contribs{i} = contributor(draw.A, draw.C, sample.D, shortE, shortX, initY);
                for j = 1 : numUnits
                    unitYXZ = [meta.extractUnitFromCells(longYXZ(1), j, dim=3), longYXZ(2), longYXZ(3)];
                    unitInitY = unitYXZ{1}(1:order, :, :);
                    shortX = unitYXZ{2}(order+1:end, :, :);
                    unitD = sample.D(:, :, j);
                    unitA = meta.extractUnitFromCells(draw.A, j, dim=3);
                    unitC = meta.extractUnitFromCells(draw.C, j, dim=3);
                    unitShortE = shortE(:, :, j);
                    unitContrib = contributor(unitA, unitC, unitD, unitShortE, shortX, unitInitY);
                    contrib{i} = [contrib{i}, unitContrib];
                end
                % contrib{i} = calculateContributions4S_(draw.A, draw.C, sample.D, shortE, shortX, initY);
            end
            contribsTbl = this.tabulateContributions(contribs, meta.ShortSpan);
        end%


        function outTbl = tabulateContributions(this, C, span)
            arguments
                this
                C (1, :) cell
                span (1, :) datetime
            end
            VARIANT_DIM = 4;
            meta = this.Meta;
            outData = cat(VARIANT_DIM, C{:});
            higherDims = {[meta.SeparableShockNames, "Exogenous", "Initials"]};
            outTbl = tablex.fromNumericArray( ...
                outData, ...
                meta.EndogenousNames, ...
                span, ...
                variantDim=VARIANT_DIM, ...
                higherDims=higherDims ...
            );
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

<<<<<<< HEAD
        varargout = forecast(varargin)
        varargout = conditionalForecast(varargin)
        varargout = prepareForContributions(varargin)
=======

        function [outTbl, contribTbl] = conditionalForecast(this, fcastSpan, options)
            %[
            arguments
                this
                fcastSpan (1, :) datetime
                options.Conditions (:, :) timetable
                options.Plan = []
                options.IncludeInitial (1, 1) logical = true
                options.Contributions (1, 1) logical = false
                options.Precontributions = []
            end
            %
            if ~isempty(options.Precontributions)
                error("Precontributions disabled");
            end
            %
            VARIANT_DIM = 3;
            CONTRIB_DIM = 3;
            meta = this.Meta;
            numY = meta.NumEndogenousConcepts;
            order = meta.Order;
            numL = numY * order;
            shortFcastSpan = datex.ensureSpan(fcastSpan);
            fcastStart = shortFcastSpan(1);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            fcastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            fcastHorizon = numel(shortFcastSpan);
            initSpan = datex.initSpanFromShortSpan(shortFcastSpan, meta.Order);
            initYXZ = this.getSomeYXZ(initSpan);
            initY = initYXZ{1};
            fcastX = tablex.retrieveData(options.Conditions, meta.ExogenousNames, shortFcastSpan);
            %
            cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, shortFcastSpan);
            cfshocks = conditional.createShocksCF(meta, options.Plan, shortFcastSpan);
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
            numPresampled = this.NumPresampled;
            progressMessage = sprintf("Conditional forecast [%g]", numPresampled);
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
            fcastY = cell(1, numPresampled);
            fcastE = cell(1, numPresampled);
            if options.Contributions
                contribs = cell(1, numPresampled);
            end
            pbar = progress.Bar(progressMessage, numPresampled*numUnits);
            for i = 1 : numPresampled
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
                    [unitY, unitE] = conditional.forecast(transpose(unitD), [unitBeta{:}], unitInitY, fcastX, fcastHorizon, legacyOptions);
                    fcastY{i} = [fcastY{i}, unitY];
                    fcastE{i} = [fcastE{i}, unitE];
                    if options.Contributions
                        unitA = cell(1, fcastHorizon);
                        unitC = cell(1, fcastHorizon);
                        for k = 1 : fcastHorizon
                            unitB = reshape(unitBeta{k}, [], numY);
                            unitA{k} = unitB(1:numL, :);
                            unitC{k} = unitB(numL+1:end, :);
                        end
                        unitContribs = calculateContributions4S_(unitA, unitC, unitD, unitE, fcastX, unitInitY);
                        contribs{i} = [contribs{i}, unitContribs];
                    end
                    pbar.increment();
                end
            end
            fcastY = cat(VARIANT_DIM, fcastY{:});
            fcastE = cat(VARIANT_DIM, fcastE{:});
            outNames = [meta.EndogenousNames, meta.ShockNames];
            outData = [fcastY, fcastE];
            outSpan = shortFcastSpan;
            if options.IncludeInitial
                outSpan = longFcastSpan;
                initData = [repmat(initY(:, :), 1, 1, numPresampled), zeros(order, numY, numPresampled)];
                outData = [initData; outData];
            end
            %
            outTbl = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=VARIANT_DIM);
            %
            contribTbl = [];
            if options.Contributions
                contribTbl = this.tabulateContributions(contribs, shortFcastSpan);
            end
            %]
        end%

        function [outputTbl, contribTbl] = forecast(this, fcastSpan, options)
            arguments
                this
                fcastSpan (1, :) datetime
                options.StochasticResiduals (1, 1) logical = true
                options.IncludeInitial (1, 1) logical = true
                options.Contributions (1, 1) logical = false
                options.Precontributions = []
            end
            %
            if ~isempty(options.Precontributions)
                error("Precontributions disabled");
            end
            %
            meta = this.Meta;
            order = meta.Order;
            fcastSpan = datex.ensureSpan(fcastSpan);
            [forecaster, tabulator] = this.ReducedForm.prepareForecaster( ...
                fcastSpan, ...
                stochasticResiduals=options.StochasticResiduals, ...
                includeInitial=options.IncludeInitial ...
            );
            numPresampled = this.NumPresampled;
            numUnits = meta.NumSeparableUnits;
            shortY = cell(1, numPresampled);
            shortX = cell(1, numPresampled);
            shortU = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            if options.Contributions
                contribs = cell(1, numPresampled);
                precontribs = double.empty(0, 0, 0, numPresampled);
                if isempty(options.Precontributions)
                    contributor = @calculateContributions4S_;
                else
                    fcastStart = fcastSpan(1);
                    precontribStart = meta.ShortStart;
                    precontribEnd = datex.shift(fcastStart, -1);
                    precontribSpan = datex.span(precontribStart, precontribEnd);
                    precontribs = tablex.retrieveData( ...
                        options.Precontributions, meta.EndogenousNames, precontribSpan, ...
                        variant=':', ...
                        permute=[1, 4, 3, 2] ...
                    );
                    histInitYXZ = this.getInitYXZ();
                    histInitY = histInitYXZ{1};
                    numY = size(histInitY, 2);
                    numContrib = size(precontribs, 3);
                    precontribs = [zeros(order, numY, numContrib, numPresampled); precontribs];
                    for i = 1 : numPresampled
                        precontribs(1:order, :, end, i) = histInitY(:, :, min(end, i));
                    end
                    precontribs = precontribs(end-order+1:end, :, :, :);
                    contributor = @extendPrecontributions4S_;
                end
            end
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [shortY{i}, shortU{i}, initY{i}, shortX{i}, draw] = forecaster(sample);
                % iterate over units
                unflatShortU = meta.reshapeCrossUnitData(shortU{i});
                unflatInitY = meta.reshapeCrossUnitData(initY{i});
                for j = 1 : numUnits
                    unitD = sample.D(:, :, j);
                    unitU = unflatShortU(:,:,j);
                    unitInitY = unflatInitY(:,:,j);
                    unitA = meta.extractUnitFromCells(draw.A, j, dim=3);
                    unitC = meta.extractUnitFromCells(draw.C, j, dim=3);
                    shortE = shocksFromResiduals_(unitU, unitD);
                    if options.Contributions
                        unitContribs = contributor(unitA, unitC, unitD, shortE, shortX{i}, unitInitY, precontribs(:, :, :, i));
                        contribs{i} = [contribs{i}, unitContribs];
                    end
                end
            end
            outputTbl = tabulator(shortY, shortU, initY, shortX);
            contribTbl = [];
            if options.Contributions
                contribTbl = this.tabulateContributions(contribs, fcastSpan);
            end
        end%
>>>>>>> b5bf7957ab8d69bb091cbf175fc1767869f151f1

        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
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


