
% base.Identifier  Abstract Identifier class for identification schemes

classdef (Abstract) Identifier ...
    < handle

    properties
        % Sampler  Handle to the reduced-form sample generating function
        Sampler

        % CandidateCounter  Total number of candidates generated so far
        CandidateCounter (1, 1) uint64 = 0
    end


    properties (SetAccess=protected)
        % SamplerCounter  Total number of samples generated so far
        SampleCounter (1,1) uint64 = 0

        % Candidator  Handle to the candidate generating function
        Candidator

        % SeparableEndogenousNames  Endogenous names or endogenous concepts
        SeparableEndogenousNames (1, :) string

        % SeparableShockNames  Shock names or shock concepts
        SeparableShockNames (1, :) string

        % BeenInitialized  True if the identifier has been initialized
        BeenInitialized (1, 1) logical = false
    end


    properties (Dependent)
        ShortClassName
    end


    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end


    methods
        function varargout = initialize(this, modelS)
            arguments
                this
                modelS (1, 1) base.Structural
            end
            %
            if this.BeenInitialized
                warning("The identifier has already been initialized.");
                return
            end
            %
            meta = modelS.getMeta();
            this.populateSeparableNames(meta);
            this.beforeInitializeSampler(modelS);
            this.initializeSampler(modelS);
            this.afterInitializeSampler(modelS);
        end%

        function deinitialize(this)
            this.BeenInitialized = false;
            this.SampleCounter = uint64(0);
            this.CandidateCounter = uint64(0);
            this.Sampler = [];
            this.Candidator = [];
        end%

        function populateSeparableNames(this, meta)
            arguments
                this
                meta (1, 1) base.Meta
            end
            this.SeparableEndogenousNames = meta.getSeparableEndogenousNames();
            this.SeparableShockNames = meta.getSeparableShockNames();
        end%

        function whenPairedWithModel(this, modelS)
        end%

        function beforeInitializeSampler(this, modelS)
        end%

        function afterInitializeSampler(this, modelS)
        end%
    end


    methods
        function out = get.ShortClassName(this)
            out = extractAfter(class(this), "base.identifier.");
        end%
    end

end

