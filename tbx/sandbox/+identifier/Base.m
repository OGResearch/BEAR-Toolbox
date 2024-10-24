
% identifier.Base  Base class for identification schemes

classdef Base < handle

    properties
        Settings
    end


    properties (SetAccess = protected)
        Preallocator
        Sampler
        SampleCounter (1,1) uint32 = 0
    end


    properties (SetAccess = private)
        BeenInitialized (1, 1) logical = false
    end


    properties (Dependent)
        ShortClassName
        % Gamma
        % StdVec
        % VarVec
    end


    properties (Constant)
        SAMPLER_INFO = struct( ...
            "NumCandidates", NaN ...
        )
    end


    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end


    methods

        function this = Base(varargin)
            this.Settings = identifier.settings.(this.ShortClassName)(varargin{:});
        end%


        function varargout = initialize(this, meta, modelR)
            arguments
                this
                meta (1, 1) meta.Structural
                modelR (1, 1) model.ReducedForm
            end
            if this.BeenInitialized
                return
            end
            this.initializeSampler(meta, modelR);
        end%


        function finalize(this, modelR)
            if ~modelR.Meta.HasCrossUnits
                numStd = modelR.Meta.NumEndogenousConcepts;
            else
                numStd = modelR.Meta.NumEndogenousNames;
            end
            if isscalar(this.Settings.StdVec)
                this.Settings.StdVec = repmat(this.Settings.StdVec, 1, numStd);
            end
            if numel(this.Settings.StdVec) ~= numStd
                error("Number of standard deviations must match number of endogenous variables");
            end
        end%
    end


    methods

        function out = get.ShortClassName(this)
            out = extractAfter(class(this), "identifier.");
        end%


        % function Gamma = get.Gamma(this)
        %     Gamma = diag(this.VarVec);
        % end%


        % function varVec = get.VarVec(this)
        %     varVec = this.Settings.StdVec .^ 2;
        % end%


        % function StdVec = get.StdVec(this)
        %     StdVec = this.Settings.StdVec;
        % end%
    end

end

