
classdef Structural ...
    < handle ...
    & base.PresampleMixin ...
    & base.TabulateMixin

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
                options.reducedForm (1, 1) base.ReducedForm
                options.identifier (1, 1) base.Identifier
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


        function deinitialize(this)
            this.ReducedForm.deinitialize();
            this.Identifier.deinitialize();
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
                "dimNames", {meta.EndogenousNames, meta.getSeparableShockNames()}, ...
                options{:} ...
            );
        end%


        function [y, sample] = simulateResponses4S(this, sample)
        % Simulate a numT x numY x numP x numUnits array of responses to
        % structural shocks for a single presampled system
        %
        % NB: needs to be adjusted for multiple units in panel models
        %
            if ~isfield(sample, "IdentificationDraw")
                sample.IdentificationDraw = this.IdentificationDrawer(sample);
            end
            draw = sample.IdentificationDraw;
            y = system.filterPulses(draw.A, sample.D);
        end%


        function [varargout] = estimateShocks(this, varargin)
%{
% # calculateShocks
%
% {==Estimate structural shocks==}
%
%}
            meta = this.Meta;
            longYX = this.DataHolder.getYX(span=meta.LongSpan);
            %
            function [Y4S, sample] = estimateShocks4S(sample)
                [Y4S, sample] = this.estimateShocks4S(sample, longYX);
            end%
            %
            options = [{"includeInitial", false}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @estimateShocks4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @zeros, ...
                "dimNames", {meta.ShockNames}, ...
                options{:} ...
            );
        end%


        function [e, sample] = estimateShocks4S(this, sample, longYX)
        % NB: needs to be adjusted for multiple units in panel models
            u = this.ReducedForm.estimateResiduals4S(sample, longYX);
            e = system.shocksFromResiduals(u, sample.D);
        end%


        function contribsTbl = calculateContributions(this, options)
            % NB: needs to be adjusted for multiple units in panel models
            arguments
                this
                options.IncludeInitial (1, 1) logical = true
            end
            %
            % Retrieve necessary meta information
            meta = this.Meta;
            order = meta.Order;
            shortSpan = meta.ShortSpan;
            %
            % Prepare data
            longYX = this.getLongYX();
            [longY, longX] = longYX{:};
            initY = longY(1:order, :, :);
            shortX = longX(order+1:end, :, :);
            %
            % Prepare history drawer
            drawer = this.HistoryDrawer;
            %
            % Prepare function for calculating contributions and preallocate
            % contributions
            [contributor, contribs] = this.prepareForContributions(shortSpan, []);
            %
            % Loop over individual presampled systems
            numPresampled = this.NumPresampled;
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                shortE = this.estimateShocks4S(sample, longYX);
                contribs{i} = contributor(draw.A, draw.C, sample.D, shortE, shortX, initY);
            end
            %
            % Organize results in an output table
            contribsTbl = this.tabulateContributions(contribs, shortSpan);
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
            higherDims = {[meta.getSeparableShockNames(), "Exogenous", "Initials"]};
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
                "dimNames", {meta.EndogenousNames, meta.getSeparableShockNames()}, ...
                options{:} ...
            );
        end%

        varargout = forecast(varargin)
        varargout = conditionalForecast(varargin)
        varargout = prepareForContributions(varargin)

        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
        end%

        function varargout = estimateResiduals(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.estimateResiduals(varargin{:});
        end%

        function varargout = getLongYX(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getLongYX(varargin{:});
        end%

        function varargout = getShortYX(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getShortYX(varargin{:});
        end%

        function varargout = getSomeYX(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getSomeYX(varargin{:});
        end%

        function varargout = getInitYX(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getInitYX(varargin{:});
        end%
    end


    methods
        function out = get.Meta(this)
            out = this.ReducedForm.Meta;
        end%

        function out = getMeta(this)
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


