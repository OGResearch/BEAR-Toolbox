
% identifier.Base  Base class for identification schemes

classdef Base < handle

    properties
        Settings
    end


    properties
        Preallocator
        Sampler
        SamplerCounter (1,1) uint32 = 0
    end


    properties (Dependent)
        Gamma
        StdVec
        VarVec
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
            className = extractAfter(class(this), "identifier.");
            this.Settings = identifier.settings.(className)(varargin{:});
        end%


        function varargout = initialize(this, model, dataYLX, varargin)
            arguments
                this
                model (1, 1) model.Structural
                dataYLX (1, 3) cell
            end
            arguments (Repeating)
                varargin
            end
            %
            this.initializeSampler(model, varargin{:});
            this.SamplerCounter = uint64(0);
        end%


        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler) && ~isempty(this.Preallocator);
        end%


        function initializePreallocator(this, YLX)
            [Y, L, X] = YLX{:};
            numY = size(Y, 2);
            numD = numY * numY;
            %
            if this.Settings.TimeVariant
                numPeriods = numT;
            else
                numPeriods = 1;
            end
            %
            function sample = preallocator(numDraws)
                sample = { ...
                    nan(numPeriods, numDraws, numD) ...
                };
            end%
            %
            this.Preallocator = @preallocator;
        end%


        function finalizeFromMetaAndReducedForm(this, strMeta, redModel)
            numY = redModel.Meta.NumEndogenousColumns;
            this.Settings.TimeVariant = redModel.Estimator.Settings.TimeVariant;
            if isscalar(this.Settings.StdVec)
                this.Settings.StdVec = repmat(this.Settings.StdVec, numY, 1);
            end
        end%
    end


    methods
        function Gamma = get.Gamma(this)
            Gamma = diag(this.VarVec);
        end%


        function varVec = get.VarVec(this)
            varVec = this.Settings.StdVec .^ 2;
        end%


        function StdVec = get.StdVec(this)
            StdVec = this.Settings.StdVec;
        end%
    end

end

