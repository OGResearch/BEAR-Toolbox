
% identifier.Base  Base class for identification schemes

classdef (Abstract) Base < handle

    properties (SetAccess=protected)
        % Sampler  Handle to the reduced-form sample generating function
        Sampler

        SampleCounter (1,1) uint64 = 0

        % Candidator  Handle to the candidate generating function
        Candidator

        CandidateCounter (1,1) uint64 = 0
    end


    properties (SetAccess=private)
        BeenInitialized (1, 1) logical = false
    end


    properties (Dependent)
        ShortClassName
    end


    properties (Constant)
        SAMPLER_INFO = struct( ...
            NumCandidates=NaN ...
        )
    end


    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end


    methods
        function varargout = initialize(this, modelS)
            arguments
                this
                modelS (1, 1) model.Structural
            end
            if this.BeenInitialized
                return
            end
            this.initializeSampler(modelS);
        end%
    end


    methods
        function out = get.ShortClassName(this)
            out = extractAfter(class(this), "identifier.");
        end%
    end

end

